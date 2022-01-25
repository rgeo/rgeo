# frozen_string_literal: true

module RuboCop
  # This class parses the special `rubocop:disable` comments in a source
  # and provides a way to check if each cop is enabled at arbitrary line.
  class CommentConfig
    # @api private
    REDUNDANT_DISABLE = 'Lint/RedundantCopDisableDirective'

    # @api private
    COP_NAME_PATTERN = '([A-Z]\w+/)*(?:[A-Z]\w+)'
    # @api private
    COP_NAMES_PATTERN = "(?:#{COP_NAME_PATTERN} , )*#{COP_NAME_PATTERN}"
    # @api private
    COPS_PATTERN = "(all|#{COP_NAMES_PATTERN})"

    # @api private
    COMMENT_DIRECTIVE_REGEXP = Regexp.new(
      "# rubocop : ((?:disable|enable|todo))\\b #{COPS_PATTERN}"
        .gsub(' ', '\s*')
    )

    CopAnalysis = Struct.new(:line_ranges, :start_line_number)

    attr_reader :processed_source

    def initialize(processed_source)
      @processed_source = processed_source
    end

    def cop_enabled_at_line?(cop, line_number)
      cop = cop.cop_name if cop.respond_to?(:cop_name)
      disabled_line_ranges = cop_disabled_line_ranges[cop]
      return true unless disabled_line_ranges

      disabled_line_ranges.none? { |range| range.include?(line_number) }
    end

    def cop_disabled_line_ranges
      @cop_disabled_line_ranges ||= analyze
    end

    def extra_enabled_comments
      extra_enabled_comments_with_names(
        extras: Hash.new { |h, k| h[k] = [] },
        names: Hash.new(0)
      )
    end

    def comment_only_line?(line_number)
      non_comment_token_line_numbers.none? do |non_comment_line_number|
        non_comment_line_number == line_number
      end
    end

    private

    def extra_enabled_comments_with_names(extras:, names:)
      each_directive do |comment, cop_names, disabled|
        next unless comment_only_line?(comment.loc.expression.line)

        if !disabled && enable_all?(comment)
          handle_enable_all(names, extras, comment)
        else
          handle_switch(cop_names, names, disabled, extras, comment)
        end
      end

      extras
    end

    def analyze # rubocop:todo Metrics/AbcSize
      analyses = Hash.new { |hash, key| hash[key] = CopAnalysis.new([], nil) }

      each_mentioned_cop do |cop_name, disabled, line, single_line|
        analyses[cop_name] =
          analyze_cop(analyses[cop_name], disabled, line, single_line)
      end

      analyses.each_with_object({}) do |element, hash|
        cop_name, analysis = *element
        hash[cop_name] = cop_line_ranges(analysis)
      end
    end

    def analyze_cop(analysis, disabled, line, single_line)
      if single_line
        analyze_single_line(analysis, line, disabled)
      elsif disabled
        analyze_disabled(analysis, line)
      else
        analyze_rest(analysis, line)
      end
    end

    def analyze_single_line(analysis, line, disabled)
      return analysis unless disabled

      CopAnalysis.new(analysis.line_ranges + [(line..line)],
                      analysis.start_line_number)
    end

    def analyze_disabled(analysis, line)
      if (start_line = analysis.start_line_number)
        # Cop already disabled on this line, so we end the current disabled
        # range before we start a new range.
        return CopAnalysis.new(analysis.line_ranges + [start_line..line], line)
      end

      CopAnalysis.new(analysis.line_ranges, line)
    end

    def analyze_rest(analysis, line)
      if (start_line = analysis.start_line_number)
        return CopAnalysis.new(analysis.line_ranges + [start_line..line], nil)
      end

      CopAnalysis.new(analysis.line_ranges, nil)
    end

    def cop_line_ranges(analysis)
      return analysis.line_ranges unless analysis.start_line_number

      analysis.line_ranges + [(analysis.start_line_number..Float::INFINITY)]
    end

    def each_mentioned_cop
      each_directive do |comment, cop_names, disabled|
        comment_line_number = comment.loc.expression.line
        single_line = !comment_only_line?(comment_line_number) ||
                      directive_on_comment_line?(comment)

        cop_names.each do |cop_name|
          yield qualified_cop_name(cop_name), disabled, comment_line_number,
                single_line
        end
      end
    end

    def directive_on_comment_line?(comment)
      comment.text[1..-1].match?(COMMENT_DIRECTIVE_REGEXP)
    end

    def each_directive
      processed_source.comments.each do |comment|
        directive = directive_parts(comment)
        next unless directive

        yield comment, *directive
      end
    end

    def directive_parts(comment)
      match = comment.text.match(COMMENT_DIRECTIVE_REGEXP)
      return unless match

      switch, cops_string = match.captures

      cop_names =
        cops_string == 'all' ? all_cop_names : cops_string.split(/,\s*/)

      disabled = %w[disable todo].include?(switch)

      [cop_names, disabled]
    end

    def qualified_cop_name(cop_name)
      Cop::Registry.qualified_cop_name(cop_name.strip, processed_source.file_path)
    end

    def all_cop_names
      @all_cop_names ||= Cop::Registry.global.names - [REDUNDANT_DISABLE]
    end

    def non_comment_token_line_numbers
      @non_comment_token_line_numbers ||= begin
        non_comment_tokens = processed_source.tokens.reject(&:comment?)
        non_comment_tokens.map(&:line).uniq
      end
    end

    def enable_all?(comment)
      _, cops = comment.text.match(COMMENT_DIRECTIVE_REGEXP).captures
      cops == 'all'
    end

    def handle_enable_all(names, extras, comment)
      enabled_cops = 0
      names.each do |name, counter|
        next unless counter.positive?

        names[name] -= 1
        enabled_cops += 1
      end

      extras[comment] << 'all' if enabled_cops.zero?
    end

    # Collect cops that have been disabled or enabled by name in a directive comment
    # so that `Lint/RedundantCopEnableDirective` can register offenses correctly.
    def handle_switch(cop_names, names, disabled, extras, comment)
      cop_names.each do |name|
        if disabled
          names[name] += 1
        elsif (names[name]).positive?
          names[name] -= 1
        else
          extras[comment] << name
        end
      end
    end
  end
end
