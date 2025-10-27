# frozen_string_literal: true

require 'test_helper'

class InterruptTests < Minitest::Test
  include TestHelper

  def interrupt_method
    interrupt_called
    Geos::Interrupt.request
  end

  def interrupt_tester
    yield
  ensure
    Geos::Interrupt.clear
  end

  def interrupt_called
    @interrupt_calls += 1
  end

  def setup
    super
    @interrupt_calls = 0
  end

  def assert_interrupt_called(times = 0)
    assert_operator(@interrupt_calls, :>, times, "Expected @interrupt_calls to be > #{times}")
  end

  def test_interrupt_with_method
    skip unless ENV['FORCE_TESTS'] || Geos::Interrupt.available?

    interrupt_tester do
      geom = read('LINESTRING(0 0, 1 0)')

      Geos::Interrupt.register(method(:interrupt_method))

      begin
        buffer = geom.buffer(1, 8)
      rescue StandardError => e
        # no-op
      ensure
        assert_match(/^InterruptedException/, e.message)
        assert_nil(buffer)
        assert_interrupt_called
      end
    end
  end

  def test_interrupt_with_block
    skip unless ENV['FORCE_TESTS'] || Geos::Interrupt.available?

    interrupt_tester do
      geom = read('LINESTRING(0 0, 1 0)')

      Geos::Interrupt.register do
        interrupt_called
        Geos::Interrupt.request
      end

      begin
        buffer = geom.buffer(1, 8)
      rescue StandardError => e
        # no-op
      ensure
        assert_match(/^InterruptedException/, e.message)
        assert_nil(buffer)
        assert_interrupt_called
      end
    end
  end

  def test_interrupt_with_proc
    skip unless ENV['FORCE_TESTS'] || Geos::Interrupt.available?

    interrupt_tester do
      geom = read('LINESTRING(0 0, 1 0)')

      prc = proc {
        interrupt_called
        Geos::Interrupt.request
      }

      Geos::Interrupt.register(prc)

      begin
        buffer = geom.buffer(1, 8)
      rescue StandardError => e
        # no-op
      ensure
        assert_match(/^InterruptedException/, e.message)
        assert_nil(buffer)
        assert_interrupt_called
      end
    end
  end

  def test_chain_interrupts
    skip unless ENV['FORCE_TESTS'] || Geos::Interrupt.available?

    interrupt_tester do
      geom = read('LINESTRING(0 0, 1 0)')
      prev = nil
      called = []

      prc_0 = proc {
        interrupt_called
        called << :prc_0
        Geos::Interrupt.request
      }

      prc_1 = proc {
        interrupt_called
        called << :prc_1
        prev&.call
      }

      Geos::Interrupt.register(prc_0)
      prev = Geos::Interrupt.register(prc_1)

      begin
        buffer = geom.buffer(1, 8)
      rescue StandardError => e
        # no-op
      ensure
        assert_match(/^InterruptedException/, e.message)
        assert_nil(buffer)
        assert_interrupt_called(1)
        assert_equal([:prc_1, :prc_0], called)
      end
    end
  end

  def test_cancel_interrupt
    skip unless ENV['FORCE_TESTS'] || Geos::Interrupt.available?

    interrupt_tester do
      geom = read('LINESTRING(0 0, 1 0)')

      Geos::Interrupt.register do
        Geos::Interrupt.request
        interrupt_called
        Geos::Interrupt.cancel
      end

      buffer = geom.buffer(1, 8)

      assert_kind_of(Geos::Polygon, buffer)
      assert_interrupt_called(1)
    end
  end

  def test_request_interrupt_without_a_callback
    skip unless ENV['FORCE_TESTS'] || Geos::Interrupt.available?

    geom = read('LINESTRING(0 0, 1 0)')
    Geos::Interrupt.request

    begin
      buffer = geom.buffer(1, 8)
    rescue StandardError => e
      assert_match(/^InterruptedException/, e.message)
      assert_nil(buffer)
    end
  end

  def test_cancel_interrupt_without_a_callback
    skip unless ENV['FORCE_TESTS'] || Geos::Interrupt.available?

    geom = read('LINESTRING(0 0, 1 0)')
    Geos::Interrupt.request
    Geos::Interrupt.cancel

    buffer = geom.buffer(1, 8)

    assert_kind_of(Geos::Polygon, buffer)
  end

  def test_interrupt_with_method_and_block
    skip unless ENV['FORCE_TESTS'] || Geos::Interrupt.available?

    assert_raises(ArgumentError) do
      Geos::Interrupt.register(method(:interrupt_method)) do
        # no-op
      end
    end
  end

  def test_interrupt_without_method_or_block
    skip unless ENV['FORCE_TESTS'] || Geos::Interrupt.available?

    assert_raises(ArgumentError) do
      Geos::Interrupt.register
    end
  end
end
