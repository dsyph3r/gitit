# Gitit

Currently under construction.

## Overview

Easy storage with Git

The goal of this library is to provide a wrapper around the Ruby
[Grit](https://github.com/mojombo/grit/) library that is easier to use. The Grit
library provides a very low level interface to a Git repository that can be complicated
to use if you just want high level Git features.

## Dependancies

 * grit

# Setup

Install bundler

```
    $ gem install bundler
```

Run `bundle` to install the gems

```
    $ bundle
```

# Testing

The test suite can be run using the following

```
cd tests
ruby suite.rb
```

# Usage

## Creating and Loading Gitit stores

To create a Gitit storage simply instantiate a Gitit instance. The first argument
will either load an existing store or create a new one.

Note: If the path is not an existing Gitit store it must be empty into order
to create a new one.

```
gitit = Gitit.new('./documents')
```

## Cloning a Gitit Store

```
gitit = Gitit.new('./documents')

# Clone the store
clone = Gitit.clone('./documents', './cloned')

# Fork the store
forked = gitit.fork('./forked')
```

## Adding, Updating and Saving files

```
gitit = Gitit.new('./documents')

# Add a file
gitit.add('hello.txt', 'Hello, World!')
# Save the file
gitit.commit('Saying hello')

# ...

# Update existing file
gitit.add('hello.txt', 'Goodbye, World!')
# Save updates
gitit.commit('Saying goodbye')
```

## Retrieving a file

```
gitit = Gitit.new('./documents')

file =  gitit.get_file('hello.txt')

puts file['name']   # hello.txt
puts file['data']   # Hello, World!
puts file['size']   # 201
```