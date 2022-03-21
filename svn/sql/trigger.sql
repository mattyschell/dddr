CREATE OR REPLACE TRIGGER populate_boro_block_trg 
BEFORE INSERT ON tax_block
FOR EACH ROW
BEGIN
    
    :NEW.boro_block := :NEW.BORO || LPAD(:NEW.BLOCK, 5, '0');
    
    IF :NEW.BORO = '1' THEN
        :NEW.label := 'Manhattan ' || :NEW.BLOCK;
    ELSIF :NEW.BORO = '2' THEN
        :NEW.label := 'Bronx ' || :NEW.BLOCK;
    ELSIF :NEW.BORO = '3' THEN
        :NEW.label := 'Brooklyn ' || :NEW.BLOCK;
    ELSIF :NEW.BORO = '4' THEN
        :NEW.label := 'Queens ' || :NEW.BLOCK;
    ELSIF :NEW.BORO = '5' THEN
        :NEW.label := 'Staten Island ' || :NEW.BLOCK;
    END IF;
    
END;

