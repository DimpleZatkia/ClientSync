# Granting permissions to client and the lawyer

#lawyer access
create user  lawyer
identified by 'lawyer';

grant all
on world.* 
to lawyer;

----------------------------------------------------------------------------------------------------------------------------------

#client access

create user  client
identified by 'client';

grant select
on world.survey 
to client;

grant select
on world.client 
to client;

--------------------------------------------------------------------------------------------------------


#Stored Procedure and Triggers to check the client's data

#1. Survey of client based on Patience,Flexibility,Impulsive and Integrity with 30% of weightage


DROP PROCEDURE IF EXISTS survey;
delimiter $$
 create procedure survey()
 begin
  Update survey set Status = Case
When mean_score>70 then '30'
When mean_score=75 and mean_score=65 then '20'
Else '10'
end
where survey_ID is not null and client_ID is not null;
 end $$
 delimiter ;
 
 call survey();
 
 select * from survey;
 
# Triggers to save the data in a backup table

DROP TRIGGER IF EXISTS `survey_backup` ;
DELIMITER $$
CREATE TRIGGER `survey_backup` before UPDATE ON `survey`	
    FOR EACH ROW
    BEGIN
       INSERT INTO survey_backup
    VALUES (OLD.Client_ID, OLD.Survey_ID, 
    OLD.Patience_score,OLD.Impulsive_score,OLD.Integrity_score,OLD.Flexibility_score,OLD.mean_score,
    OLD.Status);

    END;
    $$
    
    select * from survey_backup;



#2. Profitability Metric based on Client's Casevalue,
#Case_Strenght,Time_score,Misccellaneous_Cost,Flexibility_Score with 40% of Weightage


DROP PROCEDURE IF EXISTS Profitability_metric;
 delimiter $$
 create procedure Profitability_metric()
 begin
  update profitability_metric inner join case_quantification 
on profitability_metric.survey_Id =case_quantification.survey_id
inner join survey on case_quantification.survey_id=survey.survey_id
set total_score = if(case_strength<50,(client_casevalue*0.10+case_strength*0.3+time_score*0.10+misccosts*0.05+flexibility_score*0.45)*0.4,
(client_casevalue*0.25+case_strength*0.15+time_score*0.25+misccosts*0.05+flexibility_score*0.3)*.4);
 end $$
 delimiter ;
 
 
 
 call Profitability_metric();
 select * from Profitability_metric;
 
 # Triggers to save the data in a backup table
 
 DROP TRIGGER IF EXISTS `Profitability_Metric_backup` ;
DELIMITER $$
CREATE TRIGGER `Profitability_Metric_backup` before UPDATE ON `Profitability_Metric`	
    FOR EACH ROW
    BEGIN
       INSERT INTO Profitability_Metric_backup
    VALUES (OLD.Client_CaseValue, OLD.Client_ID, 
    OLD.CaseHistory_ID,OLD.Survey_ID,OLD.PM_ID,OLD.CM_ID,OLD.Total_score);

    END;
    $$
select * from Profitability_Metric_backup;




#3. Client's Background based on Previous case History with 25% of weightage
# Whether the current case is not conflicting with the Partner's of the Lawyer
# Whether the client has worked previously with the lawyer
# Whether the previous case of the client was convicted or not


DROP PROCEDURE IF EXISTS client_background;
delimiter $$
create procedure client_background()
 begin
  update client_backgroud inner join current_case on client_backgroud.client_id=current_case.client_id
 set case_status= Case
 when current_case.partner_id in (select current_case.partner_id
 from current_case inner join  partner on current_case.partner_id=partner.partner_id)
 then '5'
 when case_history='Yes' and client_backgroud='Convicted'
 then '10'
 
when current_case.partner_id in (select current_case.partner_id
 from current_case inner join  partner on current_case.partner_id=partner.partner_id)
 then '20'
 else '25'
 end;
 end $$
 delimiter ;
 
 call client_background();
 select * from client_backgroud;
 
 
  # Triggers to save the data in a backup table
  
  DROP TRIGGER IF EXISTS `client_backgroud_trigger` ;
DELIMITER $$
CREATE TRIGGER `client_backgroud_trigger` before UPDATE ON `client_backgroud`	
    FOR EACH ROW
    BEGIN
       INSERT INTO Client_Backgroud_trigger
    VALUES (OLD.Case_History, OLD.Client_Backgroud, 
    OLD.Client_ID,OLD.case_status);

    END;
    $$
    
    select * from client_backgroud_trigger;
    
    

#4. Judge conviction on the previous similar case with 5% weightage

DROP PROCEDURE IF EXISTS judge_conviction;
delimiter $$
 create procedure judge_conviction()
 begin
 update world.judge inner join world.casestable on casestable.judge_ID=judge.judge_ID
 set world.judge.judge_status= IF((casestable.case_decription like 'tyj') and 
 (judge.judge_decision like 'Convicted'),'No','Yes');
 end $$
 delimiter ;
 
 call judge_conviction();
 select * from judge;

  # Triggers to save the data in a backup table
  
  DROP TRIGGER IF EXISTS `Judge_backup` ;
DELIMITER $$
CREATE TRIGGER `Judge_backup` before UPDATE ON `Judge`	
    FOR EACH ROW
    BEGIN
       INSERT INTO Judge_backup
    VALUES (OLD.Judge_ID, OLD.Case_ID, 
    OLD.Case_Description,OLD.Case_Type,OLD.Judge_Name,OLD.Lawyer_ID,OLD.Judge_decision,
    OLD.Judge_status);

    END;
    $$
    
    select * from Judge_backup;
    

    
    
#2. Decision Model for the lawyer to select the client based on the above 4 factors
DROP PROCEDURE IF EXISTS decisionmodel; 
    delimiter $$
 create procedure decisionmodel()
 begin
  
  call judge_conviction();
  call client_background();
  call Profitability_metric();
  call survey();

  
  update decisionmodel inner join lawyer on decisionmodel.lawyer_id=lawyer.lawyer_id
 inner join client on client.lawyer_id=lawyer.lawyer_id
 inner join client_backgroud on client_backgroud.client_id=client.client_id
 inner join survey on survey.client_id=client_backgroud.client_id
 inner join profitability_metric on profitability_metric.survey_id=survey.survey_id
 inner join judge on judge.lawyer_id=lawyer.lawyer_id
  set finaldecision= case
  when survey.mean_score>20 and profitability_metric.total_score>35 and client_backgroud.case_status>20
  and judge.judge_status='Yes'  then 'yes'
  else 'no'
  end;
  
  
 select distinct client.client_id,client.client_name from lawyer join decisionmodel on decisionmodel.lawyer_id=lawyer.lawyer_id
 join client on client.lawyer_id=lawyer.lawyer_id where finaldecision='yes';

 end $$
 delimiter ;
 
 call decisionmodel();
 
 select * from decisionmodel;
 
 select client.client_id,client_client_name from decisionmodel join decisionmodel on decisionmodel.lawyer_id=lawyer.lawyer_id
 join lawyer on client.lawyer_id=lawyer.lawyer_id;
 # Triggers to save the data in a backup table
 
 
DROP TRIGGER IF EXISTS `decisionmodel_backup` ;
DELIMITER $$
CREATE TRIGGER `decisionmodel_backup` before UPDATE ON `decisionmodel`	
    FOR EACH ROW
    BEGIN
       INSERT INTO decisionmodel_backup
    VALUES (OLD.Decision_ID, OLD.Lawyer_id, 
    OLD.finaldecision);

    END;
    $$
    
    call decisionmodel();
    
    
    select * from decisionmodel;
