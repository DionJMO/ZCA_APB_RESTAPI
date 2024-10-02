CLASS zca_apb_restapi_bookings DEFINITION
  INHERITING FROM cl_rest_resource
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: tt_bookings TYPE STANDARD TABLE OF zca_apb_booking WITH DEFAULT KEY.
    DATA: mo_model TYPE REF TO zca_apb_bookings_model.
    METHODS:
      if_rest_resource~get REDEFINITION,
      if_rest_resource~post REDEFINITION,
      if_rest_resource~delete REDEFINITION,
      get_all_bookings,
      get_bookings_by_date
        IMPORTING iv_booking_date TYPE zca_apb_booking-datum,
      get_bookings_by_id
        IMPORTING iv_booking_id TYPE zca_apb_booking-id.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zca_apb_restapi_bookings IMPLEMENTATION.
  METHOD if_rest_resource~get.
    DATA:
      l_uri         TYPE string,
      lv_date       TYPE zca_apb_booking-datum,
      lv_booking_id TYPE zca_apb_booking-id.


    IF mo_model IS INITIAL.
      CREATE OBJECT mo_model TYPE zca_apb_bookings_model.
    ENDIF.

    " URI holen
    l_uri = me->mo_request->get_uri(  ).

    " response Handler anlegen
    mo_response->create_entity( ).

    IF find( val = l_uri regex = '\/reservations\/date/\d{8}' ) <> - 1.

      lv_date = me->mo_request->get_uri_attribute( iv_name = 'date' ).

      IF lv_date IS NOT INITIAL.
        me->get_bookings_by_date( iv_booking_date = lv_date ).
      ELSE.
        "Fehlerbehandlung, falls keine ID gefunden wurde
        mo_response->set_status( iv_status = 400 iv_reason_phrase = 'Bad Request: No ID provided').
      ENDIF.

    ELSEIF find( val = l_uri regex = '\/reservations\/id/\d' ) <> -1.
      lv_booking_id = me->mo_request->get_uri_attribute( iv_name = 'id' ).

      IF lv_booking_id IS NOT INITIAL.
        me->get_bookings_by_id( iv_booking_id = lv_booking_id ).
      ELSE.
        "Fehlerbehandlung, falls keine ID gefunden wurde
        mo_response->set_status( iv_status = 400 iv_reason_phrase = 'Bad Request: No ID provided').
      ENDIF.
    ELSEIF find( val = l_uri regex = '\/reservations'  ) <> -1.

      me->get_all_bookings( ).


    ELSE.
      " Wenn die URI nicht mit /tables übereinstimmt, Standard-Antwort senden
      mo_response->set_header_field(
       EXPORTING
         iv_name  = 'Access-Control-Allow-Origin'
         iv_value = '*.kroschke.com'
     ).

      mo_response->set_header_field(
     EXPORTING
       iv_name  = 'Content-Security-Policy'
       iv_value = '*.kroschke.com'
   ).

      mo_response->get_entity( )->set_string_data( '{ "msg": "OK!" }' ).
      mo_response->get_entity( )->set_content_type( if_rest_media_type=>gc_appl_json ).
    ENDIF.
  ENDMETHOD.


  METHOD if_rest_resource~post.
    " Deklaration der Variablen für den Request-Body als String und für das Buchungsobjekt
    DATA: lv_body_string TYPE string,
          lv_success     TYPE abap_bool,
          ls_booking     TYPE zca_apb_booking.

    IF mo_model IS INITIAL.
      CREATE OBJECT mo_model TYPE zca_apb_bookings_model.
    ENDIF.

    " Den Request-Body als JSON-String extrahieren
    lv_body_string = mo_request->get_entity( )->get_string_data( ).

    " Versuch, die Buchung in der Datenbank zu speichern
    TRY.
        /ui2/cl_json=>deserialize(
                EXPORTING
                  json = lv_body_string
                CHANGING
                  data = ls_booking ).

        " Geschäftslogik zur Erstellung einer neuen Buchung in der Model-Klasse aufrufen
        ls_booking = mo_model->create_bookings_by_date( iv_body_string = lv_body_string ).
        " ls_booking = mo_model->create_bookings_by_date( ).
        IF ls_booking IS NOT INITIAL.
          DATA(lv_id) = |{ ls_booking-id }|.
          IF mo_response IS INITIAL OR mo_response->get_entity( ) IS INITIAL.
            mo_response->create_entity( ).
          ENDIF.
          mo_response->get_entity( )->set_string_data( |{ lv_id }| ).
          " Bei Erfolg wird ein 201 Created Status zurückgegeben
          mo_response->set_status( iv_status = 201 iv_reason_phrase = 'Booking Created Successfully.' ).
          " Bei Datenbankfehlern wird ein 500 Internal Server Error zurückgegeben
        ELSE.
          mo_response->set_status( iv_status = 500 iv_reason_phrase = 'Internal Server Error: Failed to save booking.' ).
        ENDIF.

        " Bei Konvertierungsfehlern numerischer Werte wird ein 400 Fehler zurückgegeben
      CATCH cx_sy_conversion_no_number INTO DATA(lx_number_error).
        mo_response->set_status( iv_status = 400 iv_reason_phrase = 'Invalid Data: Numeric conversion error.' ).
        RETURN.
        " Bei anderen Konvertierungsfehlern wird ebenfalls ein 400 Fehler zurückgegeben
      CATCH cx_sy_conversion_error INTO DATA(lx_conv_error).
        mo_response->set_status( iv_status = 400 iv_reason_phrase = 'Invalid Data: General conversion error.' ).
    ENDTRY.
  ENDMETHOD.


  METHOD if_rest_resource~delete.
    " Deklaration der Variablen für den Request-Body als String und für das Buchungsobjekt
    DATA:
      lv_reservations_id TYPE zca_apb_booking-id,
      lv_success         TYPE abap_bool.

    IF mo_model IS INITIAL.
      CREATE OBJECT mo_model TYPE zca_apb_bookings_model.
    ENDIF.

    " Parameter aus der URL extrahieren
    lv_reservations_id = mo_request->get_uri_attribute( iv_name = 'id' ).


    IF lv_reservations_id IS NOT INITIAL.
      " Löschoperation in der Model-Klasse aufrufen
      lv_success = mo_model->delete_bookings_by_date( iv_reservations_id = lv_reservations_id ).

      IF lv_success = abap_true.
        mo_response->set_status( iv_status = 204 ). " No Content
      ELSE.
        " Fehlerbehandlung, falls keine Buchung gefunden wurde
        mo_response->set_status( iv_status = 404 ). " Not Found
      ENDIF.
    ELSE.
      " Fehlerbehandlung, falls Parameter fehlen
      mo_response->set_status( iv_status = 400 ). " Bad Request
    ENDIF.
  ENDMETHOD.

  METHOD get_all_bookings.
    DATA: lt_bookings TYPE TABLE OF zca_apb_booking.

    " Holt sich die Daten aus der Model-Klasse
    lt_bookings = mo_model->get_all_bookings( ).

    IF lt_bookings IS NOT INITIAL.
      mo_response->set_status( iv_status = 200 ).
      mo_response->get_entity( )->set_string_data( /ui2/cl_json=>serialize(
          data        = lt_bookings
          compress    = abap_true
          pretty_name = /ui2/cl_json=>pretty_mode-camel_case

      ) ).
    ELSE.
      mo_response->set_status( iv_status = 204 iv_reason_phrase = 'No Entries found!' ).
    ENDIF.


    " JSON-String als Antwort setzen
    mo_response->get_entity( )->set_content_type( if_rest_media_type=>gc_appl_json ).

    " Statuscode auf 200 OK setzen
    mo_response->set_status( iv_status = 200 ).
  ENDMETHOD.
  METHOD get_bookings_by_date.
    DATA: lt_bookings_by_date TYPE tt_bookings,
          lv_date             TYPE zca_apb_booking-datum.



    " Filtern der Buchungen nach Datum
    lt_bookings_by_date = mo_model->get_bookings_by_date( iv_date = iv_booking_date ).

    IF lt_bookings_by_date IS NOT INITIAL.
      " Serialisieren und Antwort setzen
      mo_response->set_status( iv_status = 200 ).
      mo_response->get_entity( )->set_content_type( if_rest_media_type=>gc_appl_json ).
      mo_response->get_entity( )->set_string_data( /ui2/cl_json=>serialize(
          data        = lt_bookings_by_date
          compress    = abap_true
          pretty_name = /ui2/cl_json=>pretty_mode-camel_case
      ) ).
    ELSE.
      " Keine Buchungen gefunden
      mo_response->set_status( iv_status = 204 iv_reason_phrase = 'No Entries found!' ).
    ENDIF.
    mo_response->get_entity( )->set_content_type( if_rest_media_type=>gc_appl_json ).
  ENDMETHOD.
  METHOD get_bookings_by_id.
    DATA: lt_bookings_by_id TYPE tt_bookings,
          lv_id             TYPE zca_apb_booking-id.



    " Filtern der Buchungen nach Datum
    lt_bookings_by_id = mo_model->get_bookings_by_id( iv_id = iv_booking_id ).

    IF lt_bookings_by_id IS NOT INITIAL.
      " Serialisieren und Antwort setzen
      mo_response->set_status( iv_status = 200 ).
      mo_response->get_entity( )->set_content_type( if_rest_media_type=>gc_appl_json ).
      mo_response->get_entity( )->set_string_data( /ui2/cl_json=>serialize(
          data        = lt_bookings_by_id
          compress    = abap_true
          pretty_name = /ui2/cl_json=>pretty_mode-camel_case
      ) ).
    ELSE.
      " Keine Buchungen gefunden
      mo_response->set_status( iv_status = 204 iv_reason_phrase = 'No Entries found!' ).
    ENDIF.
    mo_response->get_entity( )->set_content_type( if_rest_media_type=>gc_appl_json ).
  ENDMETHOD.

ENDCLASS.
