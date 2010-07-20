' twrc/rjson.bmx
'   reflection-based JSON encoder/decoder for BlitzMax
'   by Tyler W.R. Cole
'   written according to the JSON specification http://www.json.org
'   with the following minor modifications(s):
'   - when decoding, it is okay for numbers to have any number of leading zeroes

SuperStrict
Module twrc.rjson
Import brl.reflection
Import brl.retro


Type JSON
	
	'///////////
	'  public
	'///////////
	
	'Generate a JSON-String from an object
	Function Encode:String( source_object:Object, settings:TJSONEncodeSettings = Null, override_type:TTypeId = Null, indent% = 0 )
		If Not settings
			settings = New TJSONEncodeSettings
		End If
		If Not source_object
			Return VALUE_NULL
		Else 'source_object <> Null
			Local encoded_json_data:String = ""
			Local source_object_type_id:TTypeId
			If override_type
				source_object_type_id = override_type
			Else
				source_object_type_id = TTypeId.ForObject( source_object )
			End If
			Local type_metadata:TJSONTypeSpecificMetadata = settings.GetTypeMetadata( source_object_type_id )
			Local is_array% = source_object_type_id.ElementType() <> Null
			If Not is_array
				Select source_object_type_id
					Case StringTypeId
						encoded_json_data :+ STRING_BEGIN
						encoded_json_data :+ _StringEscape( source_object.ToString() )
						encoded_json_data :+ STRING_END
					Default 'User-Defined-Type
						encoded_json_data :+ OBJECT_BEGIN
						If settings.pretty_print Then encoded_json_data :+ "~n"
						If settings.pretty_print Then indent :+ 1
						If settings.pretty_print Then encoded_json_data :+ _RepeatSpace( indent*settings.tab_size )
						Local source_object_fields:TList = CreateList()
						Local source_object_super_type_id:TTypeId = source_object_type_id.SuperType()
						While source_object_super_type_id
							source_object_super_type_id.EnumFields( source_object_fields )
							source_object_super_type_id = source_object_super_type_id.SuperType()
						End While
						source_object_type_id.EnumFields( source_object_fields )
						Local field_count% = source_object_fields.Count()
						Local field_index% = 0
						Local value:Object
						For Local source_object_field:TField = EachIn source_object_fields
							If Not type_metadata.IsFieldIgnored( source_object_field )
								value = source_object_field.Get( source_object )
								encoded_json_data :+ STRING_BEGIN
								encoded_json_data :+ source_object_field.Name()
								encoded_json_data :+ STRING_END
								encoded_json_data :+ PAIR_SEPARATOR
								If settings.pretty_print Then encoded_json_data :+ " "
								Local source_object_field_type_id:TTypeId = source_object_field.TypeId()
								Select source_object_field_type_id
									Case ByteTypeId, ..
									     ShortTypeId, ..
										   IntTypeId, ..
									     LongTypeId, ..
									     FloatTypeId, ..
									     DoubleTypeId
										encoded_json_data :+ value.ToString()
									Default
										encoded_json_data :+ Encode( value, settings,, indent )
								End Select
								If field_index < (field_count - 1) 'Not last member
									encoded_json_data :+ MEMBER_SEPARATOR
									If settings.pretty_print Then encoded_json_data :+ "~n"
									If settings.pretty_print Then encoded_json_data :+ _RepeatSpace( indent*settings.tab_size )
								End If
							End If
							field_index :+ 1
						Next
						If settings.pretty_print Then encoded_json_data :+ "~n"
						If settings.pretty_print Then indent :- 1
						If settings.pretty_print Then encoded_json_data :+ _RepeatSpace( indent*settings.tab_size )
						encoded_json_data :+ OBJECT_END
					End Select
			Else 'Array type
				Local dimensions% = source_object_type_id.ArrayDimensions( source_object )
				Local dimension_lengths%[] = New Int[dimensions]
				For Local d% = 0 Until dimensions
					dimension_lengths[d] = source_object_type_id.ArrayLength( source_object, d )
				Next
				Local array_length% = source_object_type_id.ArrayLength( source_object )
				Local source_object_element_type_id:TTypeId = source_object_type_id.ElementType()
				Local value:Object
				For Local index% = 0 Until array_length
					For Local d% = 0 Until dimensions
						If index Mod dimension_lengths[d] = 0
							encoded_json_data :+ ARRAY_BEGIN
							If settings.pretty_print Then encoded_json_data :+ "~n"
							If settings.pretty_print Then indent :+ 1
							If settings.pretty_print Then encoded_json_data :+ _RepeatSpace( indent*settings.tab_size )
						End If
					Next
					value = source_object_type_id.GetArrayElement( source_object, index )
					Select source_object_element_type_id
						Case ByteTypeId, ..
						     ShortTypeId, ..
							   IntTypeId, ..
						     LongTypeId, ..
						     FloatTypeId, ..
						     DoubleTypeId
							encoded_json_data :+ value.ToString()
						Default
							encoded_json_data :+ Encode( value, settings,, indent )
					End Select
					Local separator% = False
					For Local d% = (dimensions-1) To 0 Step -1
						If (index + 1) Mod dimension_lengths[d] = 0
							If settings.pretty_print Then encoded_json_data :+ "~n"
							If settings.pretty_print Then indent :- 1
							If settings.pretty_print Then encoded_json_data :+ _RepeatSpace( indent*settings.tab_size )
							encoded_json_data :+ ARRAY_END
						End If
						If Not separator And (index + 1) Mod dimension_lengths[d] <> 0
							encoded_json_data :+ VALUE_SEPARATOR
							If settings.pretty_print Then encoded_json_data :+ "~n"
							If settings.pretty_print Then encoded_json_data :+ _RepeatSpace( indent*settings.tab_size )
							separator = True
						End If
					Next
				Next
			End If
			Return encoded_json_data
		End If
	End Function
	
	' Parse a JSON-String and populate an object
	Function Decode:Object( encoded_json_data:String, typeId:TTypeId = Null )
		Local cursor% = 0
		If typeId
			Local decoded_object:Object
			If Not typeId.ElementType() 'non-array type provided
				Local json_object:TMap = _DecodeJSONObject( encoded_json_data, cursor )
				If json_object
					Return _InitializeObject( json_object, typeId )
				Else
					Throw( "Error: an object is desired, but an array was found" )
					Return Null
				End If
			Else 'array type provided
				Local json_array:TList = _DecodeJSONArray( encoded_json_data, cursor )
				If json_array
					Return _InitializeArray( json_array, typeId )
				Else
					Throw( "Error: an array is desired, but an object was found" )
				End If
			End If
			Return decoded_object
		Else 'no typeId provided; return raw data
			Return _DecodeJSONValue( encoded_json_data, cursor )
		End If
	End Function
	
	Function ObjectInfo$( obj:Object )
		If obj <> Null
			Return Hex( Int( Byte Ptr( obj ))) + " " + TTypeId.ForObject( obj ).Name()
		Else
			Return Hex( 0 )
		End If
	End Function

	'///////////
	'  private
	'///////////
	
	'string, number, object, array, true, false, null
	Function _DecodeJSONValue:Object( encoded_json_data:String, cursor:Int Var )
		_EatWhitespace( encoded_json_data, cursor )
		Local temp_str$ = encoded_json_data[cursor..]
		If temp_str.StartsWith( VALUE_NULL )
			cursor :+ VALUE_NULL.Length
			Return Null
		Else If temp_str.StartsWith( VALUE_TRUE )
			cursor :+ VALUE_TRUE.Length
			Return TJSONBoolean.Create( True )
		Else If temp_str.StartsWith( VALUE_FALSE )
			cursor :+ VALUE_FALSE.Length
			Return TJSONBoolean.Create( False )
		End If
		Local char$
		char = Chr(encoded_json_data[cursor])
		Select char
			Case OBJECT_BEGIN
				Return _DecodeJSONObject( encoded_json_data, cursor )
			Case ARRAY_BEGIN
				Return _DecodeJSONArray( encoded_json_data, cursor )
			Case STRING_BEGIN
				Return _DecodeJSONString( encoded_json_data, cursor )
		End Select
		If char = "-" Or _IsDigit( char )
			Return _DecodeJSONNumber( encoded_json_data, cursor )
		End If
		Throw( "Error: could not parse encoded JSON data at position "+(cursor-1) )
		Return Null
	End Function
	
	Function _DecodeJSONObject:TMap( encoded_json_data:String, cursor:Int Var )
		Local json_object:TMap = CreateMap()
		_EatWhitespace( encoded_json_data, cursor )
		Local char$
		char = Chr(encoded_json_data[cursor]); cursor :+ 1
		If char <> OBJECT_BEGIN
			Throw( "Error: expected open-curly-brace character at position "+(cursor-1) )
			Return Null
		End If
		Local member_pair_name$, member_pair_value:Object
		Repeat
			_EatWhitespace( encoded_json_data, cursor )
			member_pair_name = _DecodeJSONString( encoded_json_data, cursor )
			_EatWhitespace( encoded_json_data, cursor )
			char = Chr(encoded_json_data[cursor]); cursor :+ 1
			If char <> PAIR_SEPARATOR
				Throw( "Error: expected colon character at position "+(cursor-1) )
				Return Null
			End If
			_EatWhitespace( encoded_json_data, cursor )
			member_pair_value = _DecodeJSONValue( encoded_json_data, cursor )
			json_object.Insert( member_pair_name, member_pair_value )
			_EatWhitespace( encoded_json_data, cursor )
			char = Chr(encoded_json_data[cursor]); cursor :+ 1
			If char <> VALUE_SEPARATOR And char <> OBJECT_END
				Throw( "Error: expected comma or close-curly-brace character at position "+(cursor-1) )
				Return Null
			End If
		Until char = OBJECT_END Or cursor >= (encoded_json_data.Length - 1)
		Return json_object
	End Function
	
	Function _DecodeJSONArray:TList( encoded_json_data:String, cursor:Int Var )
		Local json_array:TList = CreateList()
		_EatWhitespace( encoded_json_data, cursor )
		Local char$
		char = Chr(encoded_json_data[cursor]); cursor :+ 1
		If char <> ARRAY_BEGIN
			Throw( "Error: expected open-square-bracket character at position "+(cursor-1) )
			Return Null
		End If
		Local element_value:Object
		Repeat
			_EatWhitespace( encoded_json_data, cursor )
			element_value = _DecodeJSONValue( encoded_json_data, cursor )
			json_array.AddLast( element_value )
			_EatWhitespace( encoded_json_data, cursor )
			char = Chr(encoded_json_data[cursor]); cursor :+ 1
			If char <> VALUE_SEPARATOR And char <> ARRAY_END
				Throw( "Error: expected comma or close-square-bracket character at position "+(cursor-1) )
				Return Null
			End If
		Until char = ARRAY_END Or cursor >= (encoded_json_data.Length - 1)
		Return json_array
	End Function
	
	Function _DecodeJSONString:String( encoded_json_data:String, cursor:Int Var )
		Local json_string$ = ""
		_EatWhitespace( encoded_json_data, cursor )
		Local char$, char_temp$
		char = Chr(encoded_json_data[cursor]); cursor :+ 1
		If char <> STRING_BEGIN
			Throw( "Error: expected quotation character at position "+(cursor-1) )
			Return Null
		End If
		Repeat
			char = Chr(encoded_json_data[cursor]); cursor :+ 1
			If char = STRING_END
				Exit
			End If
			If char <> STRING_ESCAPE_SEQUENCE_BEGIN
				json_string :+ char
			Else
				If cursor >= (encoded_json_data.Length - 1)
					Throw( "Error: unterminated string literal" )
					Return Null
				End If
				char_temp = Chr(encoded_json_data[cursor]); cursor :+ 1
				Select char_temp
					Case STRING_ESCAPE_QUOTATION
						json_string :+ "~q"
					Case STRING_ESCAPE_REVERSE_SOLIDUS
						json_string :+ "\"
					Case STRING_ESCAPE_SOLIDUS
						json_string :+ "/"
					Case STRING_ESCAPE_BACKSPACE
						'ignore
					Case STRING_ESCAPE_FORMFEED
						'ignore
					Case STRING_ESCAPE_NEWLINE
						json_string :+ "~n"
					Case STRING_ESCAPE_CARRIAGE_RETURN
						json_string :+ "~r"
					Case STRING_ESCAPE_HORIZONTAL_TAB
						json_string :+ "~t"
					Case STRING_ESCAPE_UNICODE_BEGIN
						'ignore
						cursor :+ 4
					Default
						Throw( "Error: bad string escape sequence at position "+(cursor-1) )
						Return Null
				End Select
			End If
		Until cursor >= (encoded_json_data.Length - 1)
		Return json_string
	End Function
	
	'TJSONLong, TJSONDouble
	Function _DecodeJSONNumber:Object( encoded_json_data:String, cursor:Int Var )
		Local json_value:Object = Null
		_EatWhitespace( encoded_json_data, cursor )
		Local cursor_start% = cursor
		Local floating_point% = False
		_EatSpecific( encoded_json_data, cursor, "+-", 1 )
		_EatSpecific( encoded_json_data, cursor, "0123456789",, 1 )
		If _EatSpecific( encoded_json_data, cursor, ".", 1 )
			floating_point = True
			_EatSpecific( encoded_json_data, cursor, "0123456789",, 1 )
		End If
		If _EatSpecific( encoded_json_data, cursor, "eE", 1 )
			floating_point = True
			_EatSpecific( encoded_json_data, cursor, "+-", 1 )
			_EatSpecific( encoded_json_data, cursor, "0123456789",, 1 )
		End If
		If (cursor - cursor_start) > 0
			Local encoded_number$ = encoded_json_data[cursor_start..cursor]
			If encoded_number And encoded_number.Length > 0
				If floating_point
					json_value = TJSONDouble.Create( encoded_number.ToDouble() )
				Else
					json_value = TJSONLong.Create( encoded_number.ToLong() )
				End If
			End If
		End If
		Return json_value
	End Function
	
	Function _InitializeObject:Object( json_object:TMap, type_id:TTypeId )
		Local decoded_object:Object = type_id.NewObject()
		For Local key$ = EachIn json_object.Keys()
			Local object_field:TField = type_id.FindField( key )
			If object_field
				Local value:Object = json_object.ValueForKey( key )
				Local object_field_type_id:TTypeId = object_field.TypeId()
				If Not object_field_type_id.ElementType() 'non-array field type found
					Try
						Select object_field_type_id
							Case ByteTypeId, ..
							     ShortTypeId, ..
							     IntTypeId
								object_field.SetInt( decoded_object, TJSONLong(value).value )
							Case LongTypeId
								object_field.SetLong( decoded_object, TJSONLong(value).value )
							Case FloatTypeId
								object_field.SetFloat( decoded_object, TJSONDouble(value).value )
							Case DoubleTypeId
								object_field.SetDouble( decoded_object, TJSONDouble(value).value )
							Case StringTypeId
								object_field.Set( decoded_object, value.ToString() )
							Case ObjectTypeId
								object_field.Set( decoded_object, value )
							Default 'user defined objects
								Local json_child_object:TMap = TMap(value)
								If Not json_child_object Then Throw( "Error: an object is desired, but something else was found: "+ObjectInfo(value) )
								object_field.Set( decoded_object, _InitializeObject( json_child_object, object_field_type_id ))
						End Select
					Catch ex$
						Throw( "Error: could not assign decoded object member ("+ObjectInfo(value)+") to "+type_id.Name()+" field "+object_field.Name()+":"+object_field_type_id.Name() )
					End Try
				Else 'array field type found
					Local json_child_array:TList = TList(value)
					If Not json_child_array Then Throw( "Error: an array is desired, but something else was found: "+ObjectInfo(value) )
					object_field.Set( decoded_object, _InitializeArray( json_child_array, object_field_type_id ))
				End If
			Else
				Throw( "Error: could not find field named "+key+" within type "+type_id.Name() )
				Return Null
			End If
		Next
		Return decoded_object
	End Function
	
	Function _InitializeArray:Object( json_array:TList, type_id:TTypeId )
		Local size% = json_array.Count()
		Local decoded_object:Object = type_id.NewArray( size ) 'TODO: check for destination field being a multidimensional array
		Local index% = 0
		For Local value:Object = EachIn json_array
			Try
				type_id.SetArrayElement( decoded_object, index, value )
			Catch ex$
				Throw( "Error: could not assign decoded array element ("+ObjectInfo(value)+") to "+type_id.ElementType().Name()+"["+index+"]" )
			End Try
			index :+ 1
		Next
		Return decoded_object
	End Function
	
	Function _EatWhitespace( str:String, cursor:Int Var )
		' advance cursor to first printable character
		While cursor < str.Length And Not _IsPrintable( Chr( str[cursor] ))
			cursor :+ 1
		End While
	End Function
	
	Function _EatSpecific%( str:String, cursor:Int Var, char_filter:String, limit% = -1, require% = -1 )
		Local cursor_start% = cursor
		Local contained_in_filter% = True
		While cursor < str.Length And contained_in_filter
			contained_in_filter = False
			For Local c% = 0 Until char_filter.Length
				If str[cursor] = char_filter[c]
					contained_in_filter = True
					Exit
				End If
			Next
			If contained_in_filter
				cursor :+ 1
			End If
			If limit <> -1 And (cursor - cursor_start) >= limit
				Exit
			End If
		End While
		If require <> -1 And (cursor - cursor_start) < require
			Throw( "Error: expected at least "+require+" characters from the set ["+char_filter+"]" )
		End If
		Return cursor - cursor_start
	End Function
	
	Function _StringEscape$( str$ )
		Return str.Replace( "~q", "\~q" ).Replace( "\", "\\" ).Replace( "/", "\/" ).Replace( "~n", "\n" ).Replace( "~r", "\r" ).Replace( "~t", "\t" )  
	End Function
	
	Function _RepeatSpace$( count% )
		Return LSet( "", count )
	End Function
	
	Function _IsDigit%( char$ )
		Local ascii_code% = Asc( char )
		Return ascii_code >= Asc( "0" ) And ascii_code <= Asc( "9" )
	End Function
	
	Function _IsAlpha%( char$ )
		Local ascii_code% = Asc( char )
		Return ascii_code >= Asc( "A" ) And ascii_code <= Asc( "Z" ) ..
		Or     ascii_code >= Asc( "a" ) And ascii_code <= Asc( "z" )
	End Function
	
	Function _IsPrintable%( char$ )
		Local ascii_code% = Asc( char )
		Return ascii_code > 32 And ascii_code <> 127
	End Function
	
	'JSON ASCII Literals
	Const OBJECT_BEGIN$                  = "{"
	Const OBJECT_END$                    = "}"
	Const MEMBER_SEPARATOR$              = ","
	Const PAIR_SEPARATOR$                = ":"
	Const ARRAY_BEGIN$                   = "["
	Const ARRAY_END$                     = "]"
	Const VALUE_SEPARATOR$               = ","
	Const VALUE_TRUE$                    = "true"
	Const VALUE_FALSE$                   = "false"
	Const VALUE_NULL$                    = "null"
	Const STRING_BEGIN$                  = "~q"
	Const STRING_END$                    = "~q"
	Const STRING_ESCAPE_SEQUENCE_BEGIN$  = "\"
	Const STRING_ESCAPE_QUOTATION$       = "~q"
	Const STRING_ESCAPE_REVERSE_SOLIDUS$ = "\"
	Const STRING_ESCAPE_SOLIDUS$         = "/"
	Const STRING_ESCAPE_BACKSPACE$       = "b"
	Const STRING_ESCAPE_FORMFEED$        = "f"
	Const STRING_ESCAPE_NEWLINE$         = "n"
	Const STRING_ESCAPE_CARRIAGE_RETURN$ = "r"
	Const STRING_ESCAPE_HORIZONTAL_TAB$  = "t"
	Const STRING_ESCAPE_UNICODE_BEGIN$   = "u"
	
End Type


' encoding settings
Type TJSONEncodeSettings
	Field pretty_print:Byte '(boolean) whether to format with tabs and whitespace for human readability
	Field tab_size:Int      'spaces per tab indent level, minimum = 1
	Field metadata:TMap     'maps blitzmax type-ID's to type-specific encoding settings
	'////
	Method New()
		pretty_print = True
		tab_size = 2
		metadata = CreateMap()
	End Method
	'////
	Method GetTypeMetadata:TJSONTypeSpecificMetadata( typeId:TTypeId )
		Local type_metadata:TJSONTypeSpecificMetadata = TJSONTypeSpecificMetadata( metadata.ValueForKey( typeId ))
		If Not type_metadata
			type_metadata = New TJSONTypeSpecificMetadata
			metadata.Insert( typeId, type_metadata )
		End If
		Return type_metadata
	End Method
	'////
	Method IgnoreField( typeId:TTypeId, field_ref:TField )
		GetTypeMetadata( typeId ).IgnoreField( field_ref )
	End Method
	'////
	Method OverrideFieldType( typeId:TTypeId, field_ref:TField, field_type:TTypeId )
		GetTypeMetadata( typeId ).OverrideFieldType( field_ref, field_type )
	End Method
End Type

' type-specific metadata describes fields to ignore and fields to override with explicit types
Type TJSONTypeSpecificMetadata
	Field ignoreFields:TList      'TList<String> specifies fields to ignore
	Field fieldTypeOverrides:TMap 'maps blitzmax fields to types (to use as overrides)
	'////
	Method New()
		ignoreFields = CreateList()
		fieldTypeOverrides = CreateMap()
	End Method
	'////
	Method IsFieldIgnored%( field_ref:TField )
		Return ignoreFields.Contains( field_ref )
	End Method
	'////
	Method IsFieldTypeOverridden%( field_ref:TField )
		Return fieldTypeOverrides.Contains( field_ref )
	End Method
	'////
	Method GetFieldTypeOverride:TTypeId( field_ref:TField )
		Return TTypeId( fieldTypeOverrides.ValueForKey( field_ref ))
	End Method
	'////
	Method IgnoreField( field_ref:TField )
		ignoreFields.AddLast( field_ref )
	End Method
	'////
	Method OverrideFieldType( field_ref:TField, field_type:TTypeId )
		fieldTypeOverrides.Insert( field_ref, field_type )
	End Method
End Type



' wrapper type for integral numbers
Type TJSONLong
	Field value:Long
	'////
	Function Create:TJSONLong( value:Long )
		Local obj:TJSONLong = New TJSONLong
		obj.value = value
		Return obj
	End Function
	'////
	Method ToString:String()
		Return String.FromLong(value)
	End Method
End Type

' wrapper type for floating-point numbers
Type TJSONDouble
	Field value:Double
	'////
	Function Create:TJSONDouble( value:Double )
		Local obj:TJSONDouble = New TJSONDouble
		obj.value = value
		Return obj
	End Function
	'////
	Method ToString:String()
		Return String.FromDouble(value)
	End Method
End Type

' wrapper type for boolean values
Type TJSONBoolean
	Field value:Byte
	'////
	Function Create:TJSONBoolean( value:Byte )
		Local obj:TJSONBoolean = New TJSONBoolean
		If value Then obj.value = True Else obj.value = False
		Return obj
	End Function
	'////
	Method ToString:String()
		If value Then Return "true" Else Return "false"
	End Method
End Type

