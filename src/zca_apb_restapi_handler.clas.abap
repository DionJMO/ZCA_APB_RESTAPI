CLASS zca_apb_restapi_handler DEFINITION
  PUBLIC
  INHERITING FROM cl_rest_http_handler
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS: if_rest_application~get_root_handler REDEFINITION.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS: con_res_cls_tables   TYPE seoclsname VALUE 'ZCA_APB_RESTAPI_TABLES',
               con_res_cls_bookings TYPE seoclsname VALUE 'ZCA_APB_RESTAPI_BOOKINGS',
               con_res_cls_objects  TYPE seoclsname VALUE 'ZCA_APB_RESTAPI_OBJECTS'.
ENDCLASS.



CLASS zca_apb_restapi_handler IMPLEMENTATION.
  METHOD if_rest_application~get_root_handler.
    DATA lo_router TYPE REF TO cl_rest_router.
    CREATE OBJECT lo_router.

    " Tischklasse
    lo_router->attach( iv_template = '/tables' iv_handler_class = me->con_res_cls_tables ).
    lo_router->attach( iv_template = '/tables/{id}' iv_handler_class = me->con_res_cls_tables ).

    " Objektklasse
    lo_router->attach( iv_template = '/tables/{tableId}/objects' iv_handler_class = me->con_res_cls_objects ).
    lo_router->attach( iv_template = '/objects' iv_handler_class = me->con_res_cls_objects ).

    " Reservierungsklassen Routing
    lo_router->attach( iv_template = '/reservations' iv_handler_class = me->con_res_cls_bookings ).
    lo_router->attach( iv_template = '/reservations/id/{id}' iv_handler_class = me->con_res_cls_bookings ).
    lo_router->attach( iv_template = '/reservations/date/{date}' iv_handler_class = me->con_res_cls_bookings ).


    ro_root_handler = lo_router.
  ENDMETHOD.
ENDCLASS.
