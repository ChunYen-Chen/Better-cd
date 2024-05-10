#!/bin/bash
#====================================================================================================
# Setup:
# 1. Copy this file to somewhere (e.g. ~/Better_cd.sh).
# 2. Add the following line to your .bashrc:
#    source ~/Better_cd.sh
# 3. Resource the .bashrc by executing the command:
#    source ~/.bashrc
#
# Usage:
# 1. `cd` now also record `pwd` to the `.dir_history`
# 2. `cdl` list the directories you have been to.
# 3. `cdl 20` list 20 directories you have been.
# 4. `cdd` go to the last directory
# 5. `cdd 4` go to the fourth directory listed by `cdl`
#====================================================================================================



#====================================================================================================
# Global variables
#====================================================================================================
HIST_FILE="$HOME/.dir_history"          # history file location
HIST_FILE_REAL=`readlink $HIST_FILE`    # history file location
HIST_LIMIT=100                          # number of directory history
DEFAULT_LIST_NUMBER=10                  # default number of listing directories
DEFAULT_TARGET=2                        # default target number (2 is the last directory)
INT_RE='^[0-9]+$'                       # regular expression of integer



#====================================================================================================
# Functions
#====================================================================================================
cd() {
    command cd $1
    __record_dir
}

cdl() {
    list_num=$DEFAULT_LIST_NUMBER
    if [ $# -ne 0 ]; then list_num=$1; fi
    tail $HIST_FILE_REAL -n $list_num | tac | nl
}

cdd() {
    tar_num=$DEFAULT_TARGET
    if [ $# -ne 0 ]; then tar_num=$1; fi
    tar_dir=$(__go_dir $tar_num)

    if [ "$tar_dir" = "err1" ]; then
        echo "Wrong input of the directory number."
    elif [ "$tar_dir" = "err2" ]; then
        echo "Wrong input format. It should be integer."
    else
        cd $tar_dir
    fi
}

__go_dir ()
{
    hist_num=$(wc -l < "$HIST_FILE_REAL")

    if [ $# -eq 0 ]; then
        target_num=$(($hist_num-1))
    elif ! [[ $1 =~ $INT_RE ]]; then
        echo "err2"
        return 2
    elif [ $1 -le 0 ] || [ $1 -gt $hist_num ]; then
        echo "err1"
        return 1
    else
        target_num=$(($hist_num-$1+1))
    fi

    target=($(sed -n ${target_num}p $HIST_FILE_REAL))

    host=${target[0]}
    tar_dir=${target[1]}

    echo $tar_dir
    return 0
}

__record_dir ()
{
    record=true

    # If the last history is the same as current pwd, then don't record
    n_hist=$(wc -l < "$HIST_FILE_REAL")
    target_num=$(($n_hist))
    target=($(sed -n ${target_num}p $HIST_FILE_REAL))

    tar_dir=${target[1]}
    if [ "$tar_dir" = "$PWD" ]; then record=false; fi

    # Record the path to history
    if "$record"; then
        str_to_store=`printf "%8s %s" $HOSTNAME $PWD`
        echo "$str_to_store" >> $HIST_FILE_REAL
    fi

    # If the history reached the limit number, delete the oldest one.
    n_hist=$(wc -l < "$HIST_FILE_REAL")

    if [ $n_hist -gt $HIST_LIMIT ]; then
        sed -i '1d' "$HIST_FILE_REAL"
    fi
}



#====================================================================================================
# Main
#====================================================================================================
# If the file is not link, use the original one
if [[ -z $HIST_FILE_REAL ]] ; then HIST_FILE_REAL=$HIST_FILE ; fi

# Initialize the history file if not exist
if [ ! -f $HIST_FILE_REAL ]; then
    echo "$HIST_FILE_REAL does not exist. Create a new one!"
    touch $HIST_FILE_REAL
    str_to_store=`printf "%8s %s" $HOSTNAME $PWD`
    echo "$str_to_store" >> $HIST_FILE_REAL
fi
