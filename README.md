# README

This program times how long you spend on each git commit in a repo without needing a user to start or stop the timer manually.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'repo_timetracker'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install repo_timetracker

### How it works

It keeps track of work time by recording the timing of file changes, and of commands used within a project folder.

The exact time of each command recorded with the 'record' command and every file change in the repo is saved, along with whether or not the program thinks you were working during the intervals between these events. When commit_time is called, it adds up all of the time intervals during which it thinks you were working and returns the total.

If two sequential events occur more than half an hour apart, it assumes you weren't working during that time. Less than half an hour, it assumes you were.

Here's an example sequence of events:

```
> rpt record

...5 minutes pass...

file change

...45 minutes pass...

> rpt record 'git status'

...5 minutes pass...

file change

...5 minutes pass...

file change

> rpt commit_time
"00:15:00"
```

At the end, the commit_time command says 15 minutes have been spent working, because it counted the 3 5-minute intervals, but not the one 45-minute interval.

All data is stored in YAML files in the **.repo_timeline** directory, and is pretty easy to read and modify by hand if you're so inclined (for example, to correct one of the intervals from working to not or vice versa if the 30-minute rule fails you).

## How to use

To initialize recording for a repo (only needs to happen once per repo, ever):

``` 
> rpt record

```
To get time spent on current commit (in hh:mm:ss):

``` 
> rpt commit_time
"00:23:34"

```
To get total time spent on all commits in this repo (in hh:mm:ss):

``` 
> rpt project_time
"07:38:55"

```
Recording a git commit starts a new commit timer from zero:

```
> rpt commit_time
"00:35:23"
> git commit -am "awesome commit message $(rpt commit_time)"
[master c2f2492] awesome commit message 00:35:33
 1 file changed, 0 insertions(+), 0 deletions(-)
 rename cool_file.rb => rad_file.rb (100%)
 
> rpt record "git commit"
> rpt commit_time
"00:00:06"
```

## The commands

Commands are called with **rpt** followed by the name of the command.

#### record
'record' or 'rec' makes a record of an event that occurs within the project directory. The first time this command is run in a directory it will initialize the **.repo_timeline** folder in the root directory of that repo*. This folder is where the timing data is stored. It should be added to your **.gitignore** file.

***For repo_timetracker to work properly, 'git commit' and 'git commit --amend' calls must always be recorded.***

Example call: `rpt record 'git status'`

#### commit_time
'commit_time' or 'ct' returns the amount of time that has been spent on the current commit thus far in *hh:mm:ss* format.

Example call: `rpt commit_time`

#### project_time
'project_time' or 'pt' returns the amount of time that has been spent on the entire repo thus far in *hh:mm:ss* format.

Example call: `rpt project_time`


### What I use it for

For my purposes, I have setup a function, `rpt`, that runs the rpt script, and some functions that call `rpt record` automatically after common git commands (e.g. `git status` will be followed by `rpt record 'git status'`, `git commit` by `rpt record 'git commit'`, etc.). I use the [fish shell](http://fishshell.com/), so for me these functions look like these:

```
function gs
  git status $argv
  rpt rec "git status $argv"
end
```
```
function gca
  git commit --amend $argv
  rpt rec "git commit --amend $argv"
end
```

The function I use for git commits is setup so that it automatically appends the time spent on the commit to the end of the commit message:

```
function gc
  set -x totaltime (rpt commit_time)
  git commit -m "$argv $totaltime" # Commits with time elapsed added on to commit message
  rpt rec "git commit -m \"$argv $totaltime\"" # Records commit event
end
```
Thus:

```
> gc "awesome commit message"
```
Might produce a commit like:

```
[master c2f2492] awesome commit message 00:35:33
1 file changed, 0 insertions(+), 0 deletions(-)
rename cool_file.rb => rad_file.rb (100%)
```

I also have a display of the time spent in the current commit show in my terminal prompt, like this:
```
00:34:16 >
```


## Contributing

1. Fork it ( https://github.com/[my-github-username]/repo_timetracker/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


-----

\* It automatically determines the relevant repo as either a repo in the directory it is called from, or the nearest repo that appears in a parent of that directory.