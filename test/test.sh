#!/bin/bash
# test.sh

# PATH VARS
BACKINTIME_PATH="../common/backintime"
CONFIG_PATH="config"
TEST_PATH="/tmp/snapshots"
SNAPSHOTS_PATH="$TEST_PATH/backintime/test-host/test-user/1"
DATA_PATH="/tmp/test"

# COUNTERS
CSuccesses=0
CFails=0

#######################################################################
# COLORS

# Reset
Color_Off='\e[0m'       # Text Reset

# Regular Colors
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green

# Bold
BRed='\e[1;31m'         # Red
BGreen='\e[1;32m'       # Green
BWhite='\e[1;37m'       # White

# Background
On_Red='\e[41m'         # Red
On_Green='\e[42m'       # Green
#######################################################################


#######################################################################
test ()            #  test [condition] [name] [success] [fail] [lineno]
{                  #+ If condition false, exit from script
                   #+ with appropriate error message.
  E_PARAM_ERR=98
  E_ASSERT_FAILED=99


  if [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ] || [ -z "$5" ]; #  Not enough parameters passed
  then                    #+ to assert() function.
    return $E_PARAM_ERR   #  No damage done.
  fi

  lineno=$5

  echo -e "${BWhite}"
  echo -e "================================================================================${Color_Off}"

  echo -e "${BWhite} TEST --> $2 ${Color_Off}"

  if [ ! $1 ] 
  then
    echo "Assertion failed:  \"$1\" for test : \"$2\""
    echo "File \"$0\", line $lineno"    # Give name of file and line number.
    echo -e "${On_Red} FAIL --> $4 ${Color_Off}"

    CFails=`expr $CFails + 1`
#    exit $E_ASSERT_FAILED
  else
    echo -e "${On_Green} SUCCESS --> $3 ${Color_Off}"

    CSuccesses=`expr $CSuccesses + 1`
  fi  

  echo -e "${BWhite}================================================================================"
  echo -e "${Color_Off}"
} 
#######################################################################


# clean tmp
echo "Clean testing directory"
chmod -Rfv 777 $TEST_PATH >/dev/null && rm -rfv $TEST_PATH $DATA_PATH >/dev/null 

echo "Create testing directory"
mkdir -p $SNAPSHOTS_PATH

echo "Create testing data"
mkdir -p $DATA_PATH && touch "$DATA_PATH/test_file1"

# create backup
$BACKINTIME_PATH --config $CONFIG_PATH -b >/dev/null 2>/dev/null

test "`ls -1 $SNAPSHOTS_PATH | grep -v ^l| wc -l` -eq 1" "Test if backintime make a snapshot" "A snapshot have been created" "A snaphshot should have been created" $LINENO

# create backup but no snapshot must be created
$BACKINTIME_PATH --config $CONFIG_PATH -b >/dev/null 2>/dev/null

test "`ls -1 $SNAPSHOTS_PATH | grep -v ^l| wc -l` -eq 1" "Test if backintime does not make a useless snapshot" "No snapshot have been created" "A useless snaphshot have been created" $LINENO

# add new file in target dir
mkdir -p $DATA_PATH && touch "$DATA_PATH/test_file2"

# create backup
$BACKINTIME_PATH --config $CONFIG_PATH -b >/dev/null 2>/dev/null

test "`ls -1 $SNAPSHOTS_PATH | grep -v ^l | wc -l` -eq 2" "Test if backintime make a new snapshot on content dir change" "A snaphshot should have been created" "A snapshot have been created" $LINENO

# clean tmp
echo "Clean testing directory"
chmod -R 777 $TEST_PATH && rm -rfv $TEST_PATH $DATA_PATH >/dev/null

# SUMMARY
echo -e "${BWhite}"
echo "================================================================================"
echo "Summary integration tests :"
echo "--> Successes : ${CSuccesses} - Fails : ${CFails}"
echo "================================================================================"
echo -e "${Color_Off}"

if [ $CFails -eq 0 ]
then
    exit 0
else
    exit 1
fi

