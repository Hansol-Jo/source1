*&---------------------------------------------------------------------*
*& Report ZRSA25_006
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zrsa25_006.

PARAMETERS pa_car TYPE scarr-carrid.

*----------------------------------------------------------------------------------------------------------------
*<<<<OPEN SQL & 문법(select, loop)에서 사용하기>>>>
*--------------Old syntax
DATA: BEGIN OF ls_scarr,
        carrid   TYPE scarr-carrid,
        carrname TYPE scarr-carrname,
        url      TYPE scarr-url,
      END OF ls_scarr,
      lt_scarr LIKE TABLE OF ls_scarr.

SELECT carrid carrname url
  INTO CORRESPONDING FIELDS OF TABLE lt_scarr
  FROM scarr.

READ TABLE lt_scarr INTO ls_scarr WITH KEY carrid = 'AA'.

*----------------New Syntax
"data variable을 선언하지 않아도 바로 table이 만들어짐, 기술돼있는 필드명을 모두 인터널테이블로 만들어짐 (헤더라인이 없는 인터널 테이블)
"사용되고 바로 사라짐, 로컬
"s4 hana처럼 새로운? 곳에서 만 사용할 수 있음
"open sql에서 사용할때는 '@'사용, 문법에서 사용할 때는 '@'를 안붙임
SELECT carrid, carrname, url
  INTO TABLE @DATA(lt_scarr2)
  FROM scarr.

*READ TABLE lt_scarr2 INTO DATA(ls_scarr2) WITH KEY carrid = 'AA'.
LOOP AT lt_scarr2 INTO DATA(ls_scarr2).   "데이터 구문을 사용해서 바로 데어터를 선언해줄 수 있음

ENDLOOP.

*-------------------------------------------------------------------------------------------------------------------------
*<<<<select 구문에서 into에 변수 2개 이상을 넣기>>>>
*-------------Old syntax
DATA: lv_carrid   TYPE scarr-carrid,
      lv_carrname TYPE scarr-carrname.

SELECT SINGLE carrid carrname
  INTO ( lv_carrid, lv_carrname )
  FROM scarr
 WHERE carrid = 'AA'.

*--------------New Syntax
SELECT SINGLE carrid, carrname   "신문법에서는 ',(comma)'를 찍어줘야함
  INTO (@DATA(lv_carrid2), @DATA(lv_carrname2))    "into 구문이 여기에 있을 때 오류가 나는 경우가 있음 -> 맨 아래로 빼주면 오류 안남
  FROM scarr
 WHERE carrid = @pa_car.  " 'AA'.   "상수 이외의 변수가 오려면 반드시 '@'가 붙어야 함

*------------------------------------------------------------------------------------------------------------------------
*<<<<변수에 값 넣어주기>>>>
*------Old syntax
DATA: BEGIN OF ls_scarr3,
        carrid   TYPE scarr-carrid,
        carrname TYPE scarr-carrname,
        url      TYPE scarr-url,
      END OF ls_scarr3.

ls_scarr3-carrid = 'AA'.
ls_scarr3-carrname = 'America Airline'.
ls_scarr3-url = 'www.aa.com'.

*------New Syntax
"  '#': () 사이에 온 필드명과 똑같은 필드들을 lv_scarr3에 넣겠다
"value를 쓸때는
ls_scarr3 = VALUE #( carrid = 'AA'
                     carrname = 'America Airline'
                     url = 'www.aa.com').

ls_scarr3 = VALUE #( carrid = 'KA' ).
"이런식으로 하면 ls_scarr3이 덮어씌워지기 때문에 carrid만 남음
"기술되어 있지 않은 필드는 모두 clear됨, 기술되지 않은 것은 자동으로 clear를 해주기 떄문에 이를 활용할 수도 있음

ls_scarr3 = VALUE #( BASE ls_scarr3
                     carrid = 'KA' ).
"기술되지 않은 필드들도 모두 유지시켜 줌
*-------------------------------------------------------------------------------------------------------
*<<<< APPEND >>>>
*--------Old Syntax
DATA: BEGIN OF ls_scarr4,
        carrid   TYPE scarr-carrid,
        carrname TYPE scarr-carrname,
        url      TYPE scarr-url,
      END OF ls_scarr4,
      lt_scarr4 LIKE TABLE OF ls_scarr4.

ls_scarr4-carrid = 'AA'.
ls_scarr4-carrname = 'America Airline'.
ls_scarr4-url = 'www.aa.com'.

APPEND ls_scarr4 TO lt_scarr4.

ls_scarr4-carrid = 'KA'.
ls_scarr4-carrname = 'Korean Air'.
ls_scarr4-url = 'www.ka.com'.

APPEND ls_scarr4 TO lt_scarr4.

*---------New Syntax
REFRESH lt_scarr4.

lt_scarr4 = VALUE #(
                      ( carrid = 'AA'
                        carrname = 'America Airline'
                        url = 'www.aa.com'
                       )
                       ( carrid = 'KA'
                        carrname = 'Korean Air'
                        url = 'www.ka.com'
                       )
                    ).
"괄호가 하나의 행이기 때문에 헤더라인이 필요 없음
"값을 넣기 위해 별도의 work area가 필요하지 않음->append 불필요

"주의사항:
"BASE를 써줘야 기존의 데이터가 유지됨
lt_scarr4 = VALUE #(                                     "----> 유지안됨 그전의 데이터는 CLEAR
                      ( carrid = 'LH'
                        carrname = 'Luft Hansa'
                        url = 'www.lh.com'
                       )
                    ).

lt_scarr4 = VALUE #( BASE lt_scarr4                      "------> 기존 데이터도 유지됨
                      ( carrid = 'LH'
                        carrname = 'Luft Hansa'
                        url = 'www.lh.com'
                       )
                    ).

" loop문 돌리기
*LOOP AT itab INTO wa.
*  lt_scarr4 = VALUE #( BASE lt_scarr4
*                        ( carrid   = wa-carrid
*                          carrname = wa-carrname
*                          url      = wa-url
*                         )
*                       ).
*ENDLOOP.
*------------------------------------------------------------------------------------------------------
*<<<< MOVE >>>>
*------Old Syntax
MOVE-CORRESPONDING ls_scarr3 TO ls_scarr4.
*------New Syntax
ls_scarr4 = CORRESPONDING #( ls_scarr3 ).

*------------------------------------------------------------------------------------------------------
"ITAB의 데이터 이동 문법
"모두 같은 구조의 itab 이어야 함

*gt_color = lt_color.   "헤더라인이 없는 인터널테이블
*gt_color = lt_color[]. "헤더라인이 있는 인터널테이블
*APPEND LINES OF lt_color TO gt_color.   "lt에 있는 모든 테이블은 gt의 기존 데이터 맨 밑에 append함
*
*MOVE-CORRESPONDING lt_color TO gt_color.  "필드명이 같은 필드에 대해서 데이터가 append / 기존의 데이터가 사라짐
*
*MOVE-CORRESPONDING lt_color TO gt_color KEEPING TARGET LINES.  "필드명이 같은 필드에 대해서만 데이터가 기존 데이터의 밑으로 append

*-------------------------------------------------------------------------------------------------------
"FOR ALL ENTRY  :  DB Table과 ITAB을 JOIN할 때 사용
*----Old Syntax------------------------------------------
DATA : BEGIN OF ls_key,
         carrid TYPE sflight-carrid,
         connid TYPE sflight-connid,
         fldate TYPE sflight-fldate,
       END OF ls_key,

       lt_key   LIKE TABLE OF ls_key,
       lt_sbook TYPE TABLE OF sbook.

SELECT carrid connid fldate
  INTO CORRESPONDING FIELDS OF TABLE lt_key
  FROM sflight
 WHERE carrid = 'AA'.

* FOR ALL ENTRIES 의 선제조건
* 1. 반드시 정렬 먼저 할것 : SORT
* 2. 정렬 후 중복제거 할것
* 3. ITAB이 비어있는지 체크하고 수행할것 : 비어있으면 안된다
SORT lt_key BY carrid connid fldate.
DELETE ADJACENT DUPLICATES FROM lt_key COMPARING carrid connid fldate.

IF lt_key IS NOT INITIAL.
  SELECT carrid connid fldate bookid customid custtype
    INTO CORRESPONDING FIELDS OF TABLE lt_sbook
    FROM sbook
     FOR ALL ENTRIES IN lt_key
   WHERE carrid   = lt_key-carrid
     AND connid   = lt_key-connid
     AND fldate   = lt_key-fldate
     AND customid = '00000279'.
ENDIF.
*---New Syntax-------------------------
SORT lt_key BY carrid connid fldate.
DELETE ADJACENT DUPLICATES FROM lt_key COMPARING carrid connid fldate.

SELECT a~carrid, a~connid, a~fldate, a~bookid, a~customid
  FROM sbook AS a
 INNER JOIN @lt_key AS b
    ON a~carrid = b~carrid
   AND a~connid = b~connid
   AND a~fldate = b~fldate
 WHERE a~customid = '00000279'
  INTO TABLE @DATA(lt_sbook2).    "into가 아래로 와야 함  -> 위에 있으면 에러

*-------------------------------------------------------------------------------------------------------------
* lt_sbook2 에서 connid 의 MAX 값을 알고자 할때
*--Olde Syntax-----
SORT lt_sbook2 BY connid DESCENDING.
READ TABLE lt_sbook2 INTO DATA(ls_sbook2) INDEX 1.
*---new syntax------
SELECT MAX( connid ) AS connid    "MIN, SUM도 가능함
  FROM @lt_sbook2 AS a       "join이 아니어도 꼭 as를 줘야 함
  INTO @DATA(lv_max).        "into를 밑으로 빼야함 -> 위로 올라가면 에러남

*-----------------------------------------------------------------------------------------------------------
"<<<< SELECT & CASE >>>>>
*--------Old syntax---------
DATA: BEGIN OF gs_data,
        carrid   TYPE sflight-carrid,
        connid   TYPE sflight-connid,
        price    TYPE sflight-price,
        currency TYPE sflight-currency,
        fldate   TYPE sflight-fldate,
      END OF gs_data,
      gt_data LIKE TABLE OF gs_data.

SELECT carrid connid price currency fldate
  INTO CORRESPONDING FIELDS OF TABLE gt_data
  FROM sflight.

LOOP AT gt_data INTO gs_data.

  CASE gs_data-carrid.
    WHEN 'AA'.
      gs_data-carrid = 'BB'.

      MODIFY gt_data FROM gs_data INDEX sy-tabix TRANSPORTING carrid.
  ENDCASE.

ENDLOOP.

*-----new syntax--------------
SELECT CASE carrid
       	 WHEN 'AA' THEN 'BB'    "CARRID가 AA일때 BB로 리턴해라    WHEN, THEN이 뒤에 계속 올 수 있음
         ELSE carrid            "WHEN OTHERS를 ELSE로 씀 / ELSE 구문을 쓰지 않으면 공백으로 나옴
       END AS carrid, connid, price, currency, fldate    "ENDCASE 대신 END로 끝남 / CASE로 찾은 값을 AS를 써서 어떤 필드명으로 나올건지 적어줘야함
   INTO TABLE @DATA(lt_sflight)
   FROM sflight.
