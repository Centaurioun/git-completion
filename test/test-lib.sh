#!/bin/sh
#
# Copyright (c) 2005 Junio C Hamano
#

. ./sharness.sh

SRC_DIR="$SHARNESS_TEST_DIRECTORY"/..
TRASH_DIRECTORY="$SHARNESS_TRASH_DIRECTORY"

: "${GIT_TEST_DEFAULT_INITIAL_BRANCH_NAME:=master}"
export GIT_TEST_DEFAULT_INITIAL_BRANCH_NAME

export GIT_AUTHOR_EMAIL=author@example.com
export GIT_AUTHOR_NAME='A U Thor'
export GIT_COMMITTER_EMAIL=committer@example.com
export GIT_COMMITTER_NAME='C O Mitter'

export LC_ALL=C
export TERM=dumb

unset GIT_EDITOR

LF='
'

verbose () {
	"$@" && return 0
	echo >&4 "command failed: $(git rev-parse --sq-quote "$@")"
	return 1
}

test_unconfig () {
	config_dir=
	if test "$1" = -C
	then
		shift
		config_dir=$1
		shift
	fi
	git ${config_dir:+-C "$config_dir"} config --unset-all "$@"
	config_status=$?
	case "$config_status" in
	5) # ok, nothing to unset
		config_status=0
		;;
	esac
	return $config_status
}

test_config () {
	config_dir=
	if test "$1" = -C
	then
		shift
		config_dir=$1
		shift
	fi
	test_when_finished "test_unconfig ${config_dir:+-C '$config_dir'} '$1'" &&
	git ${config_dir:+-C "$config_dir"} config "$@"
}

test_config_global () {
	test_when_finished "test_unconfig --global '$1'" &&
	git config --global "$@"
}

test_tick () {
	if test -z "${test_tick+set}"
	then
		test_tick=1112911993
	else
		test_tick=$((test_tick + 60))
	fi
	GIT_COMMITTER_DATE="$test_tick -0700"
	GIT_AUTHOR_DATE="$test_tick -0700"
	export GIT_COMMITTER_DATE GIT_AUTHOR_DATE
}

write_script () {
	{
		echo "#!${2-"$SHELL_PATH"}" &&
		cat
	} >"$1" &&
	chmod +x "$1"
}

test_set_editor () {
	FAKE_EDITOR="$1"
	export FAKE_EDITOR
	EDITOR='"$FAKE_EDITOR"'
	export EDITOR
}

sane_unset () {
	unset "$@"
	return 0
}

test_set_prereq PERL
test_set_prereq SYMLINKS
test_set_prereq FUNNYNAMES

git init "$TRASH_DIRECTORY" || exit
