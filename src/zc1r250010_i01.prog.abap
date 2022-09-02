*&---------------------------------------------------------------------*
*& Include          ZC1R250010_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.

  CALL METHOD : gcl_grid->free( ), gcl_container->free( ).

  FREE : gcl_grid, gcl_container.

  LEAVE TO SCREEN 0.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE gv_okcode.
    WHEN 'CREATE'.
      CLEAR gv_okcode.
      PERFORM create_row.
    WHEN 'DELETE'.
      PERFORM delete_row.
    WHEN 'SAVE'.
      CLEAR gv_okcode.
      PERFORM save_emp.
    WHEN 'REFRESH'.
      CLEAR gv_okcode.
      PERFORM get_emp_data.
      PERFORM refresh_grid.
  ENDCASE.

ENDMODULE.
