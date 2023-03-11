# Lab Report 5 - Grading Script

## The shell script

```
CPATH='.:../../lib/hamcrest-core-1.3.jar:../../lib/junit-4.13.2.jar'

rm -rf student-submission
git clone $1 student-submission
echo 'Finished cloning'
echo ""
cd student-submission
find . -name "ListExamples.java" > file-finding.txt

if grep -q "ListExamples.java" file-finding.txt
then     
    rm -rf submission-test
    mkdir submission-test

    if ! [[ -f ListExamples.java ]]
    then
        DIR=$(grep "ListExamples.java" file-finding.txt)
        cp $DIR submission-test
        echo "Note: Wrong directory"
        echo ""
    else
        cp ListExamples.java submission-test
    fi

    cp ../TestListExamples.java submission-test
    cd submission-test
    javac ListExamples.java 2> error-output.txt
    if [[ $? -ne 0 ]]
    then
        echo "Compile failed. Message:"
        echo ""
        cat error-output.txt
        exit
    else
        if ! grep -q "class ListExamples {" ListExamples.java
        then 
            echo "Note: Incorrect class name"
            echo ""
        fi

        if ! (grep -q "static List<String> filter(List<String> list, StringChecker sc) {" ListExamples.java \
            && grep -q "static List<String> merge(List<String> list1, List<String> list2) {" ListExamples.java)
        then
            echo "Note: Incorrect method signature(s)"
            echo ""
        fi

        javac -cp $CPATH TestListExamples.java
        java -cp $CPATH org.junit.runner.JUnitCore TestListExamples 1> test-output.txt
        if grep -q "OK" test-output.txt ; then
            total=$(grep -Eo '[0-9]+' test-output.txt | tail -1)
            failed=0
        else
            read failed total <<< $(grep -Eo '[0-9]+' test-output.txt | tail -2 | awk '{print $1, $2}')
        fi
        passed=$(($total - $failed))
        echo "[passed / total]: [$passed / $total]"
        echo "Grade: $(($passed/$total*100))%"
    fi
else
    echo "No or invalid file name or type"
    exit
fi
cd ..
```
