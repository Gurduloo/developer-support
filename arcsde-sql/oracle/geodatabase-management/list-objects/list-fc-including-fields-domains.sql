/***********************************************************************

list-fc-including-fields-domains.SQL  --  List Esri Field Types

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

Purpose:
 This script serves to describe feature classes within the GDB_ITEMS
table by listing the name and type of Esri field as this differs
from DBMS field types. Requires ST_SHAPELIB to be set up and working.

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

History:

Christian Wells        08/31/2015               Original coding.

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

Versions Supported:
EGDB: 10.0 and above
DBMS: Oracle
DBMS Version: All
ST_SHAPELIB: Required

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

Tags:
XML, Fields, Oracle, Feature Class, Domains

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

Resources:
XMLQUERY:
http://docs.oracle.com/cd/B19306_01/server.102/b14200/functions224.htm

***********************************************************************/


--Return all Fields, Types, Domain Names, and Domain Types for features classes

WITH D AS
(
  SELECT ITEMS.NAME          AS "FEATURECLASS",
    XMLTBL.FNAME             AS "FIELD_NAME",   --Field Name
    SUBSTR(XMLTBL.FTYPE, 14) AS "FIELD_TYPE",   --Esri Field Type
    XMLTBL.FDOM              AS "FIELD_DOMAIN"  --Domain Name (NULL if none specified)  
  FROM SDE.GDB_ITEMS_VW ITEMS
  INNER JOIN SDE.GDB_ITEMTYPES ITEMTYPES ON items.TYPE = itemtypes.uuid,
    XMLTABLE('/Info' PASSING --Create XML table from XMLQUERY
    (
    --Query XML for information on fields
    XMLQUERY('for $i in /DEFeatureClassInfo/GPFieldInfoExs
  for $f in $i/GPFieldInfoEx
  return <Info nm="{$f/Name}" fType="{$f/FieldType}" fDom="{$f/DomainName}"/>' PASSING XMLTYPE(ITEMS.DEFINITION) RETURNING CONTENT) ) COLUMNS FNAME VARCHAR(30) PATH '@nm', FTYPE VARCHAR(30) PATH '@fType', FDOM VARCHAR(30) PATH '@fDom') XMLTBL
  WHERE itemtypes.name IN ('Feature Class', 'Table')
)
SELECT 
  D.FEATURECLASS,        --Name of featureclass
  D.FIELD_NAME,          --Field Name
  D.FIELD_TYPE,          --Esri Field Type
  D.FIELD_DOMAIN,        --Domain Name (NULL if none specified)  
  T.NAME DOMAIN_TYPE     --Type of Domain (Coded Value, Range, etc)
FROM D
LEFT JOIN SDE.GDB_ITEMS I ON D."FIELD_DOMAIN" = I.NAME
LEFT JOIN SDE.GDB_ITEMTYPES T ON I.TYPE = T.UUID;
