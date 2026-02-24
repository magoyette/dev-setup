#!/bin/bash

echo "Replacing all Git aliases"
git config --global --remove-section alias

# List all aliases
git config --global alias.alias 'config --get-regexp ^alias\.'

# Add (. to add all except deletions)
git config --global alias.a 'add'

# Add all
git config --global alias.aa 'add -A'

# Add all except new files
git config --global alias.at 'add -u'

# Add interactively with initial menu
git config --global alias.ai 'add -i'

# Add interactively without the initial menu
git config --global alias.ap 'add -p'

git config --global alias.br 'branch'
git config --global alias.bra 'branch -a'
git config --global alias.brc 'checkout -b'
git config --global alias.brd 'branch -d'

git config --global alias.ch 'checkout'
git config --global alias.clean 'clean -fdxn'
git config --global alias.co 'commit'
git config --global alias.coa 'commit --amend'

git config --global alias.d 'diff'
git config --global alias.dtd '-c diff.external=difft diff'
git config --global alias.dl 'diff --cached HEAD^'
git config --global alias.dtdl '-c diff.external=difft diff --cached HEAD^'
git config --global alias.ds 'diff --staged'
git config --global alias.dtds '-c diff.external=difft diff --staged'


git config --global alias.f 'fetch'
git config --global alias.fp 'fetch --prune'

git config --global alias.l 'log'
git config --global alias.dtl '-c diff.external=difft log -p --ext-diff'
git config --global alias.lo 'log --oneline --decorate'
git config --global alias.lg 'log --oneline --decorate --graph'
git config --global alias.ll 'log --decorate --stat'

git config --global alias.m 'merge'

git config --global alias.pl 'pull'
git config --global alias.plr 'pull --rebase'
git config --global alias.ps 'push'
git config --global alias.psf 'push -f'

git config --global alias.rb 'rebase'
git config --global alias.rbi 'rebase -i'
git config --global alias.rbc 'rebase --continue'
git config --global alias.rba 'rebase --abort'
git config --global alias.rel 'remote -v'
git config --global alias.reo 'remote show origin'

git config --global alias.s 'status'
git config --global alias.ss 'status -s'
git config --global alias.st 'stash'

# Apply by index from stash
git config --global alias.sta 'stash apply'

git config --global alias.stl 'stash list'
git config --global alias.stp 'stash pop'
git config --global alias.sts 'stash show -u'
git config --global alias.std 'stash show -u -p'
git config --global alias.stu 'stash -u'

# Rollback unstaged changes
git config --global alias.unm 'checkout --'

# Rollback staged changes and keep modifications (unstage)
git config --global alias.uns 'reset HEAD --'

# Stop tracking a file (untrack)
git config --global alias.unt 'rm --cached --'
