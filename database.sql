
-- -----------------------------------------------------
-- Table Groups
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS Groups (
  id INT NOT NULL ,
  name TEXT ,
  color VARCHAR(9) NOT NULL ,
  uuid VARCHAR(64) NOT NULL ,
  PRIMARY KEY (id) )
;

CREATE UNIQUE INDEX uuid_g_UNIQUE ON Groups (uuid ASC) ;


-- -----------------------------------------------------
-- Table Activity
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS Activity (
  id INT NOT NULL ,
  name TEXT NOT NULL ,
  description TEXT NULL ,
  image TEXT NULL ,
  PRIMARY KEY (id) )
;


-- -----------------------------------------------------
-- Table Papers
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS Papers (
  id INT NOT NULL ,
  uuid VARCHAR(64) NOT NULL ,
  title TEXT NULL ,
  text TEXT NULL ,
  ctime INT NOT NULL ,
  cdate INT NOT NULL ,
  mtime INT NOT NULL ,
  mdate INT NOT NULL ,
  activity INT NOT NULL ,
  grp INT NOT NULL ,
  PRIMARY KEY (id) ,
  CONSTRAINT fk_Papers_Groups
    FOREIGN KEY (grp )
    REFERENCES Groups (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_Papers_Activity1
    FOREIGN KEY (activity )
    REFERENCES Activity (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
;

CREATE UNIQUE INDEX uuid_UNIQUE ON Papers (uuid ASC) ;

CREATE INDEX fk_Papers_Groups_idx ON Papers (grp ASC) ;

CREATE INDEX ctime_index ON Papers (ctime ASC) ;

CREATE INDEX cdate_index ON Papers (cdate ASC) ;

CREATE INDEX mtime_index ON Papers (mtime ASC) ;

CREATE INDEX mdate_index ON Papers (mdate ASC) ;

CREATE INDEX fk_Papers_Activity1_idx ON Papers (activity ASC) ;


-- -----------------------------------------------------
-- Table Files
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS Files (
  paper INT NOT NULL ,
  file TEXT NOT NULL ,
  adate INT NOT NULL ,
  atime INT NOT NULL ,
  PRIMARY KEY (paper, file) ,
  CONSTRAINT fk_Files_Papers1
    FOREIGN KEY (paper )
    REFERENCES Papers (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
;

CREATE INDEX fk_Files_Papers1_idx ON Files (paper ASC) ;


-- -----------------------------------------------------
-- Table General
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS General (
  property TEXT NOT NULL ,
  value TEXT NULL ,
  PRIMARY KEY (property) )
;


-- -----------------------------------------------------
-- Table Sync
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS Sync (
  id TEXT NOT NULL ,
  revision INT NULL DEFAULT -1,
  last_revision INT NULL DEFAULT -1,
  PRIMARY KEY (id) )
;

CREATE INDEX revision_index ON Sync (revision ASC) ;

CREATE INDEX last_revision_index ON Sync (last_revision ASC) ;

