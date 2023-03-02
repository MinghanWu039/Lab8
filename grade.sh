CPATH='.:../../lib/hamcrest-core-1.3.jar:../../lib/junit-4.13.2.jar'

rm -rf student-submission
git clone $1 student-submission
echo 'Finished cloning'
cd student-submission
if [[ -f ListExamples.java ]]
then
    rm -rf submission-test
    mkdir submission-test
    cp ../TestListExamples.java submission-test
    cp ListExamples.java submission-test
    cd submission-test
    javac ListExamples.java 2> error-output.txt
    if [[ $? -ne 0 ]]
    then
        echo "Compile failed. Message:"
        cat error-output.txt
        exit
    else
        javac -cp $CPATH TestListExamples.java
        java -cp $CPATH org.junit.runner.JUnitCore TestListExamples 1> test-output.txt
        echo "Test result:"
        grep Test test-output.txt
        grep OK test-output.txt
    fi
else
    echo "Invalid file name or type"
    exit
fi
cd ..