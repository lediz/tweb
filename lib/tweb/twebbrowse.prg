#include 'hbclass.ch'
#include 'common.ch'

#xcommand BLOCKS ADDITIVE <v>[ PARAMS [<v1>] [,<vn>] ] => ;
	#pragma __cstream |<v>+= InlinePrg( ReplaceBlocks( %s, "{{", "}}" [,<(v1)>][+","+<(vn)>] [, @<v1>][, @<vn>] ) )

	
CLASS TWebBrowse FROM TWebControl


	DATA cId						INIT 'table'
	DATA oForm					
		
	DATA hCols						INIT {=>}
	DATA lAdd 						INIT .F.
	DATA lEdit						INIT .F.
	DATA aBtn						INIT {}
	DATA lPrint						INIT .F.
	DATA lExport					INIT .F.
	DATA lSearch					INIT .F.
	DATA lMultiSelect				INIT .F.
	DATA lSingleSelect				INIT .F.
	DATA lClickSelect				INIT .F.
	DATA lTools						INIT .F.
	DATA lSmall						INIT .T.
	DATA lDark						INIT .F.
	DATA nHeight					INIT 400
	DATA cLocale					INIT "en-EN"
	DATA cData						INIT ''

	METHOD New() 					CONSTRUCTOR
	METHOD SetData( aData )
	METHOD AddCol()
	
	
	METHOD Activate()


ENDCLASS 

METHOD New( oParent, cId, nHeight, lSingleSelect, lMultiSelect, lClickSelect, lPrint, lExport, lSearch, lTools ) CLASS TWebBrowse

	DEFAULT cId 			TO cId
	DEFAULT nHeight			TO 400
	DEFAULT lSingleSelect	TO .F.
	DEFAULT lMultiSelect	TO .F.
	DEFAULT lClickSelect	TO .F.
	DEFAULT lPrint			TO .T.
	DEFAULT lExport			TO .F.
	DEFAULT lSearch			TO .F.
	DEFAULT lTools			TO .F.

	::cId 			:= cId
	::nHeight 		:= nHeight
	::lSingleSelect := lSingleSelect
	::lMultiSelect 	:= lMultiSelect
	::lClickSelect 	:= lClickSelect
	::lPrint 		:= lPrint
	::lExport 		:= lExport
	::lSearch 		:= lSearch
	::lTools 		:= lTools			

	IF Valtype( oParent ) == 'O'	
		oParent:AddControl( SELF )	
	ENDIF

RETU SELF

METHOD AddCol( cId, hCfg, cHead, nWidth, lSortable, cAlign, cFormatter ) CLASS TWebBrowse

	LOCAL hDefCol	:= {=>}
	
	IF Valtype( hCfg ) == 'H'

		HB_HCaseMatch( hCfg, .F. ) 

		hDefCol[ 'head' ] 		:= HB_HGetDef( hCfg, 'head'		, cId ) 
		hDefCol[ 'width' ] 		:= HB_HGetDef( hCfg, 'width'	, '' ) 
		hDefCol[ 'sortable' ] 	:= HB_HGetDef( hCfg, 'sortable'	, .F. ) 
		hDefCol[ 'align' ]		:= HB_HGetDef( hCfg, 'align'	, '' ) 
		hDefCol[ 'formatter' ]	:= HB_HGetDef( hCfg, 'formatter'	, '' ) 
	
	ELSE
	
		DEFAULT cHead 			TO cId
		DEFAULT nWidth 			TO ''
		DEFAULT lSortable		TO .F.
		DEFAULT cAlign			TO ''
		DEFAULT cFormatter		TO ''
	
		hDefCol[ 'head' ] 		:= cHead
		hDefCol[ 'width' ] 		:= nWidth
		hDefCol[ 'sortable' ] 	:= lSortable 	
		hDefCol[ 'align' ]		:= cAlign
		hDefCol[ 'formatter' ]	:= cFormatter
	
	ENDIF
	
	
	::hCols[ cId ] := hDefCol		

RETU NIL

METHOD SetData( aData ) CLASS TWebBrowse

	::cData := hb_jsonencode( aData )	
	
RETU NIL

METHOD Activate() CLASS TWebBrowse

	local oThis		:= SELF
	local cHtml 	:= ''	
	local cClass 	:= ''
	
	if ::lSmall
		cClass += 'table-sm '
	endif
	
	if ::lDark
		cClass += 'table-dark '
	endif
	
	IF !empty(::cClass)
		cClass += ' ' + ::cClass
	ENDIF
	
	
	BLOCKS ADDITIVE cHtml PARAMS oThis, cClass
	
			<div class="col-12" style="padding:0px;">		<!-- //	ULL !!! Padding a pelo !!!!			-->
				<table id="{{ oThis:cId }}" class="{{ cClass }}"  
					data-multiple-select-row="{{ IF( oThis:lMultiSelect, 'true',  'false') }}"
					data-single-select="{{ IF( oThis:lSingleSelect, 'true',  'false') }}"
					data-click-to-select="{{ IF( oThis:lClickSelect, 'true',  'false') }}"
					data-height="{{ oThis:nHeight }}"
					data-locale="{{ oThis:cLocale }}"
					data-search="{{ IF( oThis:lSearch, 'true',  'false') }}"
					data-search-time-out="200"
					data-search-align="right"
					data-show-search-clear-button="true"
					data-show-toggle="{{ IF( oThis:lTools, 'true',  'false') }}"
					data-show-fullscreen="{{ IF( oThis:lTools, 'true',  'false') }}"
					data-show-columns="{{ IF( oThis:lTools, 'true',  'false') }}"
					data-show-print="{{ IF( oThis:lPrint, 'true',  'false') }}"
					data-show-export="{{ IF( oThis:lExport, 'true',  'false') }}"
					>
					<thead  class="thead-dark">
						<tr>
							
							<!--<th data-field="_keyno" data-width="70" data-align="center">Id</th>-->
						
							<?prg
								local cHtml 	:= ''
								//local nBtn 	:= {{ len(oThis:aBtn) }}
								//local lEdit 	:= {{ oThis:lEdit }} 
								local lMultiSelect	:= {{ oThis:lMultiSelect }} 
								local lSingleSelect	:= {{ oThis:lSingleSelect }} 
								local hCols 	:= {{ oThis:hCols }} 										
								local nWidth  	:= 0	
								local n, cField, hDef
								
								IF lMultiSelect .OR. lSingleSelect
								
									cHtml += '<th data-field="st" data-checkbox="true"></th>'
								
								ENDIF

								
								FOR n := 1 TO Len(hCols)
								
									aField 	:= HB_HPairAt( hCols, n )
									cField	:= aField[1]
									hDef 	:= aField[2]													
									
									cHtml += '<th data-field="' + cField + '" '
									cHtml += 'data-width="' + valtochar(hDef[ 'width' ]) + '" '
									cHtml += 'data-sortable="' + IF( hDef[ 'sortable' ], 'true', 'false' ) + '" '
									cHtml += 'data-align="' + hDef[ 'align' ] + '" '
									cHtml += 'data-formatter="' + hDef[ 'formatter' ] + '" '
									cHtml += '>' + hDef[ 'head' ] + '</th>'							
									
								NEXT						
								/*
								IF lEdit .or. nBtn > 0
							
									IF lEdit 
										nWidth := 100
									ENDIF
									
									IF nBtn > 0							
										nWidth += ( nBtn * 30 )														
									ENDIF																				
						
									cHtml += '<th data-field="operate" data-formatter="Col_Actions" data-align="center" data-width="' + ltrim(str(nWidth)) + '" >Action</th>'
								ENDIF
								*/

								retu cHtml												
							?>

							
						</tr>
						
					</thead>
					
				</table>

			</div>
				
	
	ENDTEXT 
	
	IF !Empty( ::cData )

		cHtml += '<script>'
		cHtml += "  console.log( 'INITDATA');"
		cHtml += "  var data = JSON.parse( '" + ::cData + "' );"
		cHtml += "  console.log( 'DATA', data );"
		cHtml += "  var $table = $('#" + ::cId + "');"
		cHtml += "  $table.bootstrapTable({data: data});"
		cHtml += "  console.log( 'FINAL', '===========================' );"
		cHtml += '</script>'
	
	ENDIF	


RETU cHtml