# git-retouch

Reset timestamps in a Git working tree to match the last time files were touched
by commits

## What it does

This script imbues Git with a `retouch` command. From within any Git checkout,
you can run:

    git retouch

and the files in your checkout will have their timestamps set to the most recent
time that a Git commit made changes to them.

## Why would anyone want that?

Git purists will tell you that timestamps don't matter in Git because Git itself
doesn't store information about timestamps on files.  The times that commits
were made are all that matters.

They are correct to a point.  But sometimes it is useful to know the relative
ages of files in a particular Git checkout.  And to my knowledge, after all
these years, Git still doesn't provide anything nearly as useful as a good old
`ls -lt` or `dir /o:-d` from the command line.

git-retouch makes that possible.

## How to install

First, make sure you have Ruby.  (Sorry for the inconvenience, Perl and Python
fans, but take heart: I _do_ consider this to be a bug, and I hope to port this
to Perl in the future so that it will work out-of-the-box with any Git
installation.)

Next, simply put the `git-retouch` script anywhere on your path so Git can find
it.  Take care to rename it to `git-retouch` without the file extension, or at
least to make a link named `git-retouch` without the extension.

## Public domain

I, Lawrence Leonard Gilbert, dedicate this work to the public domain.
