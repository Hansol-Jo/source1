*&---------------------------------------------------------------------*
*& Include          YCL100_001_CLS
*&---------------------------------------------------------------------*
" ALV
" 1. LIST
"    ㄴ WRITE
" 2. Functional ALV
"    ㄴ reuse
" 3. Class ALV
"    ㄴ Simple ALV ( 편집불가 )
"    ㄴ Grid ALV ( 대다수 )
"    ㄴ ALV with IDA( 최신 )

" Container
" 1. Custom Container
" 2. Docking Container
" 3. Splitter Container

DATA: GR_CON     TYPE REF TO CL_GUI_DOCKING_CONTAINER,
      GR_SPLIT   TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
      GR_CON_TOP TYPE REF TO CL_GUI_CONTAINER,
      GR_CON_ALV TYPE REF TO CL_GUI_CONTAINER.

DATA: GR_ALV      TYPE REF TO CL_GUI_ALV_GRID,
      GS_LAYOUT   TYPE LVC_S_LAYO,
      GT_FIELDCAT TYPE LVC_T_FCAT,
      GS_FIELDCAT TYPE LVC_S_FCAT,

      GS_VARIANT  TYPE DISVARIANT,
      GV_SAVE     TYPE C.
