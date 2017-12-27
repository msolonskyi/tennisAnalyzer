create or replace trigger match_scores_bi
                          before insert on match_scores
                          for each row
begin
    if :new.ID is null then
        select seq_tennis.nextval
        into :new.ID
        From Dual;
    end if;
end match_scores_bi;
/
