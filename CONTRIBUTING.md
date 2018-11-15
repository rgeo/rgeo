# Contributing

## Do you have a question?

GitHub Issues are used for bug reports and new features.

Please ask questions about how to use the library on
[Stack Overflow](https://stackoverflow.com/questions/tagged/rgeo).

## Did you find a bug?

* Ensure the bug was not already reported by searching [Issues](https://githhub.com/rgeo/rgeo/issues).

* If you're unable to find an open issue addressing the problem,
[open a new one](https://github.com/rgeo/rgeo/issues).
Be sure to include a title and clear description, as much relevant information as possible,
and a code sample demonstrating the expected behavior that is not occurring.

## Did you fix a bug or add a feature?

* Open a new GitHub pull request with the patch.

* Ensure the PR description clearly describes the problem and solution.
Include the relevant issue number if applicable.

## How to set up a development environment:

##### Fork the repo:

```sh
git clone git@github.com:rgeo/rgeo.git
```

##### Install gem dependencies:

```sh
bundle install
```

##### Install Geos (optional)

(OSX)
```sh
brew install geos
```

(Ubuntu)
```sh
apt-get install libgeos-dev
```

##### Make sure the tests pass:

```sh
bundle exec rake
```

##### Check that your code style is OK

```sh
rubocop
```
