# ClientSync

Problem: It is difficult to filter out clients based on the cases they bring to the law firm and on their history, decreasing workplace productivity
Solution: I proposed a solution to filter clients based on certain clients’ features and parameters and a system which could decide whether the client’s case is to be accepted or not based on those features and parameters. The gap that is being bridged here is assessing the expectations of client and evaluating if this can be something which the legal team shares a possible expectation, hence enhancing workplace productivity, saving money and time, bringing the law firm at a larger platform.

ER DIAGRAM
Our Legal consulting process required 15 tables to capture the process in a complete fashion. The
key was in quantifying the significance of every metric, maintaining database consistency and
understanding entity dependencies. The process was drafted from end to end by linking the
Survey (Client Behavior), Profitability metric, Client background and judge analytics into the
decision model.

![alt text](https://github.com/DimpleZatkia/ClientSync/blob/main/Capture.PNG)

ACTIVITY DIAGRAM

![alt text](https://github.com/DimpleZatkia/ClientSync/blob/main/Capture_2.PNG)

USE CASE DIAGRAM

![alt text](https://github.com/DimpleZatkia/ClientSync/blob/main/Capture_3.PNG)

SEQUENCE DIAGRAM

![alt text](https://github.com/DimpleZatkia/ClientSync/blob/main/Capture_4.PNG)


SQL IMPLEMENTATION
IMPLEMENTATION SUMMARY
The project is implemented in a way that it covers all the important learnings of this subject.
We have 16 table entries and 5 backup tables used by triggers. We have used 5 stored
procedures each one for evaluating a criterion and a main one to give a decision. The stored
procedures use update query so there can be a data issue, to handle this we need backup, so
we have created triggers for each stored procedure. There is a view created to give the
decision result so that we do not have to write a whole query every time to see the result.
For user access and privileges, we have created two different kinds of users with different
access permissions.

IMPLEMENTATION Table (Entity)
The project is about client evaluation and filtering and we have designed an algorithm to
filter the clients. There is no manual process required which saves a lot of time. The selection is
done based on 4 criteria’s Survey, profitability, background and judge’s behavior in similar
cases. We have designed an algorithm that considers all these factors and scores each of them on
their merits, each criterion has a fixed score set and the final decision is calculated using the
formulae. The profitability is the major deciding factor followed by survey and background. If all
the criteria’s match, then the decision table is updated to Yes.

CONCLUSION
We have been able to implement the project successfully with the decision model working and
giving the desired result. We were able to use all the learnings from this subject like stored
procedures, triggers, views along with joins and subqueries. There can be a further improvement
in the implementation if we can in cooperate decision model into the system, in this way we will
be able to give more accurate decisions with more number of parameters. 
