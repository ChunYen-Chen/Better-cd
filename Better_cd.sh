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
B_CD_HIST_FILE="$HOME/.dir_history"            # history file location
B_CD_HIST_FILE_REAL=`readlink $B_CD_HIST_FILE` # history file location
B_CD_HIST_LIMIT=100                            # number of directory history
B_CD_DEFAULT_LIST_NUMBER=10                    # default number of listing directories
B_CD_DEFAULT_TARGET=2                          # default target number (2 is the last directory)



#====================================================================================================
# Functions
#====================================================================================================
cd() {
    command cd $1
    __record_dir
}

cdl() {
    local list_num=$B_CD_DEFAULT_LIST_NUMBER
    if [ $# -ne 0 ]; then list_num=$1; fi
    tail $B_CD_HIST_FILE_REAL -n $list_num | tac | nl
}

cdd() {
    local tar_num=$B_CD_DEFAULT_TARGET
    if [ $# -ne 0 ]; then tar_num=$1; fi
    local tar_dir=$(__go_dir $tar_num)

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
    local hist_num=$(wc -l < "$B_CD_HIST_FILE_REAL")
    local int_re='^[0-9]+$' # regular expression of integer

    if [ $# -eq 0 ]; then
        local target_num=$(($hist_num-1))
    elif ! [[ $1 =~ $int_re ]]; then
        echo "err2"
        return 2
    elif [ $1 -le 0 ] || [ $1 -gt $hist_num ]; then
        echo "err1"
        return 1
    else
        local target_num=$(($hist_num-$1+1))
    fi

    local target=($(sed -n ${target_num}p $B_CD_HIST_FILE_REAL))

    local host=${target[0]}
    local tar_dir=${target[1]}

    echo $tar_dir
    return 0
}

__record_dir ()
{
    local record=true

    # If the last history is the same as current pwd, then don't record
    local n_hist=$(wc -l < "$B_CD_HIST_FILE_REAL")
    local target_num=$(($n_hist))
    local target=($(sed -n ${target_num}p $B_CD_HIST_FILE_REAL))

    local tar_dir=${target[1]}
    if [ "$tar_dir" = "$PWD" ]; then record=false; fi

    # Record the path to history
    if "$record"; then
        local str_to_store=`printf "%8s %s" $HOSTNAME $PWD`
        echo "$str_to_store" >> $B_CD_HIST_FILE_REAL
    fi

    # If the history reached the limit number, delete the oldest one.
    n_hist=$(wc -l < "$B_CD_HIST_FILE_REAL")

    if [ $n_hist -gt $B_CD_HIST_LIMIT ]; then
        sed -i '1d' "$B_CD_HIST_FILE_REAL"
    fi
}



#====================================================================================================
# Main
#====================================================================================================
# If the file is not link, use the original one
if [[ -z $B_CD_HIST_FILE_REAL ]] ; then B_CD_HIST_FILE_REAL=$B_CD_HIST_FILE ; fi

# Initialize the history file if not exist
if [ ! -f $B_CD_HIST_FILE_REAL ]; then
    echo "$B_CD_HIST_FILE_REAL does not exist. Create a new one!"
    touch $B_CD_HIST_FILE_REAL
    printf "%8s %s" $HOSTNAME $PWD >> $B_CD_HIST_FILE_REAL
fi
