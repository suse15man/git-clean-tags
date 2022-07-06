# git-clean-tags

Script Requirements
Please create a documented Bash script to remove old tags from a git repository. The script should take a few non-positional arguments/options:
A date (string): tags of this date and older will be removed:
	example: --date 2021-02-17
A repository path to operate upon:
	example: --repo https://github.com/kubernetes/kubernetes
Options:
dry-run mode. If present output the value of given arguments and exit
A debug mode?
Usage?
If the script is invoked without any arguments/options, the script should print a usage message and exit.

If the user interrupts the execution of the script by entering Ctlr-c keys, the script should output the following message (and exit): “The execution of the script was aborted due to user entering Ctrl-c”

Please think about how you’ll debug this to be 100% sure you don’t accidentally delete recent tags. (Doing so could have major problems for most CI/CD systems.)

Hint: There are many ways to get the list of tags, but that’s not the important part of this question. So here is one way to do it:
git for-each-ref --sort=taggerdate --format='%(tag)___%(taggerdate:raw)' refs/tags \
  | grep -v '^___' \
  | awk 'BEGIN {FS="___"} {t=strftime("%Y-%m-%d",$2); printf("%s %s\n", t, $1)}'
