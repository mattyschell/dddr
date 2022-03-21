CREATE OR REPLACE PACKAGE DOF_TAXMAP.PKG_ALTERATION_BOOK
IS
   TYPE curSearchResults
   IS
   REF CURSOR;

   TYPE curDetails
   IS
   REF CURSOR;


   PROCEDURE PROC_GET_BOROS(
     outResults OUT curDetails
   );

   PROCEDURE PROC_GET_BORO_BLOCK(
        inBorough IN VARCHAR,
        inBlock IN VARCHAR,
         inSection IN VARCHAR,
      inVolume IN VARCHAR,
        inChangeType IN VARCHAR,
        inSortColumn in varchar,
        inSortOrder in varchar,
     outResults OUT curDetails
   );

      PROCEDURE PROC_GET_BORO_VOLUME(
        inSection IN VARCHAR,
        inVolume IN VARCHAR,
        inChangeType IN VARCHAR,
        inSortColumn in varchar,
        inSortOrder in varchar,
     outResults OUT curDetails
   );
     PROCEDURE PROC_GET_MAP_INSET(
      inSection IN varchar,
     outResults OUT curDetails
   );
      PROCEDURE PROC_GET_MAP_LIBRARY_PDF(
      inParentId IN varchar,
      inChildId IN varchar,
     outResults OUT curDetails
   );
     PROCEDURE PROC_GET_MAP_INSET_PDF(
     inSection IN varchar,
     outResults OUT curDetails
   );


   PROCEDURE PROC_DETAILS_AIR_RIGHTS(
      inTransNum IN NUMBER,
      outResults OUT curDetails
   );

   PROCEDURE PROC_DETAILS_BOUNDARY_LINE(
      inTransNum IN NUMBER,
      outResults OUT curDetails
   );

   PROCEDURE PROC_DETAILS_CONDO(
      inTransNum IN NUMBER,
      outResults OUT curDetails
   );

   PROCEDURE PROC_DETAILS_CONDO_UNIT(
      inTransNum IN NUMBER,
      outResults OUT curDetails
   );

   PROCEDURE PROC_DETAILS_REUC(
      inTransNum IN NUMBER,
      outResults OUT curDetails
   );

   PROCEDURE PROC_DETAILS_SUB_RIGHTS(
      inTransNum IN NUMBER,
      outResults OUT curDetails
   );

   PROCEDURE PROC_DETAILS_TAX_LOT(
      inTransNum IN NUMBER,
      outResults OUT curDetails
   );



    PROCEDURE PROC_SEARCH_AIR_RIGHTS(
        inDateType IN VARCHAR,
        inStartDate IN VARCHAR,
        inEndDate IN VARCHAR,
        inToday IN NUMBER,
        inLastDays IN NUMBER,
        inLastYears IN NUMBER,
        inBorough IN NUMBER,
        inBlock IN NUMBER,
        inAirRightsNum IN NUMBER,
        inChangeType IN VARCHAR,  inSortColumn in varchar,
        inSortOrder in varchar,
        outResults OUT curSearchResults
    );

    PROCEDURE PROC_SEARCH_BOROUGH_BLOCK(
        inDateType IN VARCHAR,
        inStartDate IN VARCHAR,
        inEndDate IN VARCHAR,
        inToday IN NUMBER,
        inLastDays IN NUMBER,
        inLastYears IN NUMBER,
        inBorough IN NUMBER,
        inBlock IN NUMBER,
        inChangeType IN VARCHAR,
          inSortColumn in varchar,
        inSortOrder in varchar,
        outResults OUT curSearchResults
    );

PROCEDURE PROC_SEARCH_BOROUGH_BLOCK_SORT(
        inDateType IN VARCHAR,
        inStartDate IN VARCHAR,
        inEndDate IN VARCHAR,
        inToday IN NUMBER,
        inLastDays IN NUMBER,
        inLastYears IN NUMBER,
        inBorough IN NUMBER,
        inBlock IN NUMBER,
        inChangeType IN VARCHAR,
        inSortColumn in varchar,
        inSortOrder in varchar,
        outResults OUT curSearchResults
    );

    PROCEDURE PROC_SEARCH_BOROUGH_BLOCK_LOT(
        inDateType IN VARCHAR,
        inStartDate IN VARCHAR,
        inEndDate IN VARCHAR,
        inToday IN NUMBER,
        inLastDays IN NUMBER,
        inLastYears IN NUMBER,
        inBorough IN NUMBER,
        inBlock IN NUMBER,
        inLot IN NUMBER,
        inChangeType IN VARCHAR,
          inSortColumn in varchar,
        inSortOrder in varchar,
        outResults OUT curSearchResults
    );

    PROCEDURE PROC_SEARCH_BOUNDARY_LINE(
        inDateType IN VARCHAR,
        inStartDate IN VARCHAR,
        inEndDate IN VARCHAR,
        inToday IN NUMBER,
        inLastDays IN NUMBER,
        inLastYears IN NUMBER,
        inBorough IN NUMBER,
        inBlock IN NUMBER,
        inLineType IN VARCHAR,
        inChangeType IN VARCHAR,  inSortColumn in varchar,
        inSortOrder in varchar,
        outResults OUT curSearchResults
    );

    PROCEDURE PROC_SEARCH_CONDO(
        inDateType IN VARCHAR,
        inStartDate IN VARCHAR,
        inEndDate IN VARCHAR,
        inToday IN NUMBER,
        inLastDays IN NUMBER,
        inLastYears IN NUMBER,
        inBorough IN NUMBER,
        inCondoNum IN NUMBER,
        inChangeType IN VARCHAR,
          inSortColumn in varchar,
        inSortOrder in varchar,
        outResults OUT curSearchResults
    );

    PROCEDURE PROC_SEARCH_REUC(
        inDateType IN VARCHAR,
        inStartDate IN VARCHAR,
        inEndDate IN VARCHAR,
        inToday IN NUMBER,
        inLastDays IN NUMBER,
        inLastYears IN NUMBER,
        inREUCIdent IN VARCHAR,
        inChangeType IN VARCHAR,  inSortColumn in varchar,
        inSortOrder in varchar,
        outResults OUT curSearchResults
    );

    PROCEDURE PROC_SEARCH_SUB_RIGHTS(
        inDateType IN VARCHAR,
        inStartDate IN VARCHAR,
        inEndDate IN VARCHAR,
        inToday IN NUMBER,
        inLastDays IN NUMBER,
        inLastYears IN NUMBER,
        inBorough IN NUMBER,
        inBlock IN NUMBER,
        inSubNum IN NUMBER,
        inChangeType IN VARCHAR,
          inSortColumn in varchar,
        inSortOrder in varchar,
        outResults OUT curSearchResults
    );

   PROCEDURE PROC_GET_HAB_LIST(
      inBorough IN VARCHAR,
      inBlock IN VARCHAR,
      inSection IN VARCHAR,
      inVolume IN VARCHAR,
      outResults OUT curDetails
   );

   PROCEDURE PROC_GET_HAB_PDF(
      inParentId IN VARCHAR,
      outResults OUT curDetails
   );
   
END;
/