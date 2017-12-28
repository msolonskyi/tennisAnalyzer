create or replace trigger match_stats_bi
                          before insert on match_stats
                          for each row
begin
    if :new.ID is null then
        select seq_tennis.nextval
        into :new.ID
        From Dual;
    end if;
end match_stats_bi;
/
