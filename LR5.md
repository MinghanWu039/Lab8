# Lab Report 5 - Grading Script

In this markdown, I demonstrate my implementation of a grading script following the specifications in week 6 lab.

It is based on this given [repository](https://github.com/ucsd-cse15l-w23/list-examples-grader), which includes
the starter codes of the server and the test java file.


## The shell script

grade.sh

```Ruby
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
        if ! (grep -q "class ListExamples" ListExamples.java && grep -q \ 
            "interface StringChecker" ListExamples.java)
        then 
            echo "Note: Incorrect class name or interface definition"
            echo ""
            exit
        fi

        if ! (grep -q "static List<String> filter(List<String> list, StringChecker sc)" ListExamples.java \
            && grep -q "static List<String> merge(List<String> list1, List<String> list2)" ListExamples.java)
        then
            echo "Note: Incorrect method signature(s)"
            echo ""
            exit
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

## The test file

TestListExamples.java

```Ruby
import static org.junit.Assert.*;
import org.junit.*;
import java.util.Arrays;
import java.util.List;

class IsMoon implements StringChecker {
  public boolean checkString(String s) {
    return s.equalsIgnoreCase("moon");
  }
}

public class TestListExamples {

  @Test(timeout = 500)
  public void testFilter() {
    List<String> list = Arrays.asList("moon", "moo", "tra", "moOn", "noom");
    List<String> result = ListExamples.filter(list, new IsMoon());
    List<String> expected = Arrays.asList("moon", "moOn");
    assertEquals(expected, result);
  }

  @Test(timeout = 500)
  public void testMergeRightEnd() {
    List<String> left = Arrays.asList("a", "b", "c");
    List<String> right = Arrays.asList("a", "d");
    List<String> merged = ListExamples.merge(left, right);
    List<String> expected = Arrays.asList("a", "a", "b", "c", "d");
    assertEquals(expected, merged);
  }

  @Test(timeout = 500)
  public void testMergeLeftEnd() {
    List<String> left = Arrays.asList("a", "b", "e");
    List<String> right = Arrays.asList("a", "d");
    List<String> merged = ListExamples.merge(left, right);
    List<String> expected = Arrays.asList("a", "a", "b", "d", "e");
    assertEquals(expected, merged);
  }
}
```

## Directory structure

* list-examples-grader
    * grade.sh
    * ExecHelpers.class
    * GradeServer.class
    * Handler.class
    * Server.class
    * ServerHttpHandler.class
    * URLHandler.class
    * TestListExamples.java
    * GradeServer.java
    * Server.java
    * lib
        * hamcrest-core-1.3.jar
        * junit-4.13.2.jar

Note: All java files, except for `TestListExamples.java`, have been compiled. `TestListExamples.java` is compiled in the shell script.

Note: The shell script is supposed to create (in most cases) the following directory under `list-examples-grader`:

* student-submission
    * file-finding.txt
    * ListExamples.java
    * submission-test
        * (test java files and classes)
        * (a copy of student submission, both .class and .java)
        * test-output.txt

## Worked Examples

First, I run the GradeServer with the argument (the portal number) `4038`:
```
list-examples-grader % java GradeServer 4038

Server Started! Visit http://localhost:4038 to visit.
```

Then, I go to the browser and open the link. This is the initial page:

![p1]()

### link 1

https://github.com/ucsd-cse15l-f22/list-methods-lab3

Add this link as part of the query: `http://localhost:4038/grade?repo=https://github.com/ucsd-cse15l-f22/list-methods-lab3`

Press enter and here is the result:

![p2]()

Here, the first two lines show that we have successfully copies the repo to the local.

No problems with the files and directories, so no notification appears.

The last two lines show that the implementation fails two tests of the total of three tests. A score is calculated by 
dividing the tests passed by tests in total. So the score is 33%.

### link 2

https://github.com/ucsd-cse15l-f22/list-methods-corrected

Replace the query with this link: `http://localhost:4038/grade?repo=https://github.com/ucsd-cse15l-f22/list-methods-corrected`

Result:

![p3]()

Here, we can see the correct implementation passes all tests and gets 100%.

### link 3

https://github.com/ucsd-cse15l-f22/list-methods-compile-error

Replace the query with this link: `http://localhost:4038/grade?repo=https://github.com/ucsd-cse15l-f22/list-methods-compile-error`

Result:

![p4]()

The java file submitted cannot compile. The script shows the compile error message.

### link 4

https://github.com/ucsd-cse15l-f22/list-methods-signature

Replace the query with this link: `http://localhost:4038/grade?repo=https://github.com/ucsd-cse15l-f22/list-methods-signature`

Result:

![p5]()

Before compiling, the script finds out that the method signature inside the java file isn't correct.
In this case, it makes no sense to test the file. Hence, a notification is sent out.

### link 5

https://github.com/ucsd-cse15l-f22/list-methods-filename

Replace the query with this link: `http://localhost:4038/grade?repo=https://github.com/ucsd-cse15l-f22/list-methods-filename`

Result:

![p6]()

The script cannot find the java file with the name `ListExamples.java` in any place inside the repo. So instead of continuing,
it sends out a notification.

### link 6

https://github.com/ucsd-cse15l-f22/list-methods-nested

Replace the query with this link: `http://localhost:4038/grade?repo=https://github.com/ucsd-cse15l-f22/list-methods-nested`

Result:

![p7]()

The script cannot find the java file with the name `ListExamples.java` directly under the repo, but it can find it in
some nested directory. In this case, it sends a notification but goes on with the process (after copying the file to the
right place).

## Final Words

This is the last lab report. I want to thank you for your work and assistance. Although the course material has been challenging for me,
I have indeed learned a lot.

Thank you and good luck with whatever you need luck for :)

