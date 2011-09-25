' test suite for bmx-rjson
SuperStrict
Import twrc.rjson
'Import "rjson.bmx"

'////////////////////////////////////////
'////////////////////////////////////////
'////////////////////////////////////////
Print( "~n~ntest suite 0 - wrapper types" )

'////////////////////////////////////////
Print( "~ntest 0.1 - null - Null" )
Try
	Print JSON.Encode( Null )
Catch ex$
	Print "Test FAILED with Exception: "+ex
End Try

'////////////////////////////////////////
Print( "~ntest 0.2 - boolean - (JSON only)" )
Try
	Local b:TJSONBoolean
	b = TJSONBoolean.Create( True )
	Print JSON.Encode( b )
	b = TJSONBoolean.Create( False )
	Print JSON.Encode( b )
Catch ex$
	Print "Test FAILED with Exception: "+ex
End Try

'////////////////////////////////////////
Print( "~ntest 0.3 - number - (Byte/Short/Int/Long)" )
Try
	Local nl:TJSONLong
	nl = TJSONLong.Create( Byte(85) )
	Print JSON.Encode( nl )
	nl = TJSONLong.Create( Short(85) )
	Print JSON.Encode( nl )
	nl = TJSONLong.Create( Int(85) )
	Print JSON.Encode( nl )
	nl = TJSONLong.Create( Long(85) )
	Print JSON.Encode( nl )
Catch ex$
	Print "Test FAILED with Exception: "+ex
End Try

'////////////////////////////////////////
Print( "~ntest 0.4 - number - (Float/Double)" )
Try
	Local settings:TJSONEncodeSettings = New TJSONEncodeSettings
	Local nd:TJSONDouble
	Print "precision = default (maximum)"
	nd = TJSONDouble.Create( Float(85.1) )
	Print JSON.Encode( nd )
	nd = TJSONDouble.Create( Double(85.1) )
	Print JSON.Encode( nd )
	Print "precision = 7"
	settings.default_precision = 7
	nd = TJSONDouble.Create( Float(85.1) )
	Print JSON.Encode( nd, settings )
	nd = TJSONDouble.Create( Double(85.1) )
	Print JSON.Encode( nd, settings )
	Print "precision = 4"
	settings.default_precision = 4
	nd = TJSONDouble.Create( Float(85.1) )
	Print JSON.Encode( nd, settings )
	nd = TJSONDouble.Create( Double(85.1) )
	Print JSON.Encode( nd, settings )
	Print "precision = 1"
	settings.default_precision = 1
	nd = TJSONDouble.Create( Float(85.1) )
	Print JSON.Encode( nd, settings )
	nd = TJSONDouble.Create( Double(85.1) )
	Print JSON.Encode( nd, settings )
	Print "precision = 0"
	settings.default_precision = 0
	nd = TJSONDouble.Create( Float(85.1) )
	Print JSON.Encode( nd, settings )
	nd = TJSONDouble.Create( Double(85.1) )
	Print JSON.Encode( nd, settings )
Catch ex$
	Print "Test FAILED with Exception: "+ex
End Try


'////////////////////////////////////////
'////////////////////////////////////////
'////////////////////////////////////////
Print( "~n~ntest suite 1 - encoding" )
Local jstr:String
Local settings:TJSONEncodeSettings = New TJSONEncodeSettings
Local type_id:TTypeId

'////////////////////////////////////////
Print( "~ntest 1.1 - int array" )
Try
	Local arr_i:Int[] = [ 1, 2, 3, 40, 41, 42, 101 ]
	'///
	settings.pretty_print = False
	Print( "  -pretty_print" )
	jstr = JSON.Encode( arr_i, settings )
	Print( jstr )
	'///
	settings.pretty_print = True
	Print( "  +pretty_print" )
	jstr = JSON.Encode( arr_i, settings )
	Print( jstr )
Catch ex$
	Print "Test FAILED with Exception: "+ex
End Try

'////////////////////////////////////////
Print( "~ntest 1.2 - object of arbitrary type (ExampleData)" )
'///
Type ExampleData
	Field b:Byte
	Field s:Short
	Field i:Int
	Field l:Long
	Field f:Float
	Field d:Double
	Field str:String
	Field bx:Byte[]
	Field sx:Short[]
	Field ix:Int[]
	Field lx:Long[]
	Field fx:Float[]
	Field dx:Double[]
	Field strx:String[]
	Field o1str:Object
	Field o1x:Object
	Field o1udt:Object
End Type
'///
Type ExampleUserDefinedType
	Field a:Int
	Field b:Int
	Field c:Int
End Type
'///
Local ex_d:ExampleData
'Try
	ex_d = New ExampleData
	ex_d.b = 135
	ex_d.s = 36700
	ex_d.i = 1587492043
	ex_d.l = 4958248718354
	ex_d.f = 0.00004524
	ex_d.d = 1498510.459
	ex_d.str = "Hello, World!"
	ex_d.bx = [ Byte(12), Byte(23), Byte(135), Byte(3) ]
	ex_d.sx = [ Short(1000), Short(3000), Short(5000), Short(20400) ]
	ex_d.ix = [ 1475, 192334, 4952408 ]
	ex_d.lx = [ Long(4498524), Long(4198475049), Long(8968763549) ]
	ex_d.fx = [ 0.2498, 0.004245, 14356000.0 ]
	ex_d.dx = [ Double(1.29854e24), Double(1.4985), Double(0.024587e-31) ]
	ex_d.strx = [ "Hello 1", "Hello 2", "Hello 3" ]
	ex_d.o1str = "String"
	ex_d.o1x = [ "String 1", "String 2", "String 3" ]
	Local udt:ExampleUserDefinedType = New ExampleUserDefinedType
	udt.a = 50
	udt.b = 100
	udt.c = 150
	ex_d.o1udt = udt
	'///
	settings.pretty_print = False
	Print( "  -pretty_print" )
	jstr = JSON.Encode( ex_d, settings )
	Print( jstr )
	'///
	settings.pretty_print = True
	Print( "  +pretty_print" )
	jstr = JSON.Encode( ex_d, settings )
	Print( jstr )
'Catch ex$
'	Print "Test FAILED with Exception: "+ex
'End Try

'////////////////////////////////////////
Print( "~ntest 1.2b: +ignoreFields( l, f, d, strx )" )
Try
	type_id = TTypeId.ForName("ExampleData")
	settings.IgnoreField( type_id, type_id.FindField("l") )
	settings.IgnoreField( type_id, type_id.FindField("f") )
	settings.IgnoreField( type_id, type_id.FindField("d") )
	settings.IgnoreField( type_id, type_id.FindField("strx") )
	jstr = JSON.Encode( ex_d, settings )
	Print( jstr )
	settings:TJSONEncodeSettings = New TJSONEncodeSettings
Catch ex$
	Print "Test FAILED with Exception: "+ex
End Try

'////////////////////////////////////////
Print( "~ntest 1.3 - array of arrays" )
Try
	Local arr_arr_i:Int[][][] = [ [ [ 0, 1 ], [ 2, 3 ] ], [ [ 4, 5 ], [ 6, 7 ] ] ]
	'///
	settings.pretty_print = False
	Print( "  -pretty_print" )
	jstr = JSON.Encode( arr_arr_i, settings )
	Print( jstr )
	'///
	settings.pretty_print = True
	Print( "  +pretty_print" )
	jstr = JSON.Encode( arr_arr_i, settings )
	Print( jstr )
Catch ex$
	Print "Test FAILED with Exception: "+ex
End Try

'////////////////////////////////////////
Print( "~ntest 1.4 - multi-dimensional array" )
Try
	Local arr2d_i:Int[,,] = New Int[2,2,2]
	arr2d_i[0,0,0] = 0
	arr2d_i[0,0,1] = 1
	arr2d_i[0,1,0] = 2
	arr2d_i[0,1,1] = 3  
	arr2d_i[1,0,0] = 4
	arr2d_i[1,0,1] = 5 
	arr2d_i[1,1,0] = 6 
	arr2d_i[1,1,1] = 7 
	'///
	settings.pretty_print = False
	Print( "  -pretty_print" )
	jstr = JSON.Encode( arr2d_i, settings )
	Print( jstr )
	'///
	settings.pretty_print = True
	Print( "  +pretty_print" )
	jstr = JSON.Encode( arr2d_i, settings )
	Print( jstr )
Catch ex$
	Print "Test FAILED with Exception: "+ex
End Try

'////////////////////////////////////////
Print( "~ntest 1.5 - TList" )
Try
	Local ls:TList = CreateList()
	ls.AddLast( "String Value!" )
	ls.AddLast( [ 0, 1, 2, 4, 8 ] )
	ls.AddLast( CreateList() )
	ls.AddLast( New Int[0] )
	ls.AddLast( TJSONDouble.Create( 0.001 ))
	ls.AddLast( TJSONLong.Create( 256 ))
	ls.AddLast( TJSONBoolean.Create( True ))
	'///
	settings.pretty_print = False
	Print( "  -pretty_print" )
	jstr = JSON.Encode( ls, settings )
	Print( jstr )
	'///
	settings.pretty_print = True
	Print( "  +pretty_print" )
	jstr = JSON.Encode( ls, settings )
	Print( jstr )
Catch ex$
	Print "Test FAILED with Exception: "+ex
End Try

'////////////////////////////////////////
Print( "~ntest 1.6 - TMap" )
Try
	Local mp:TMap = CreateMap()
	mp.Insert( "key1", "String Value!" )
	mp.Insert( "key2", [ 0, 1, 2, 4, 8 ] )
	mp.Insert( "key3", CreateList() )
	mp.Insert( "key4", New Int[0] )
	mp.Insert( "key5", TJSONDouble.Create( 0.001 ))
	mp.Insert( "key6", TJSONLong.Create( 256 ))
	mp.Insert( "key7", TJSONBoolean.Create( True ))
	'///
	settings.pretty_print = False
	Print( "  -pretty_print" )
	jstr = JSON.Encode( mp, settings )
	Print( jstr )
	'///
	settings.pretty_print = True
	Print( "  +pretty_print" )
	jstr = JSON.Encode( mp, settings )
	Print( jstr )
Catch ex$
	Print "Test FAILED with Exception: "+ex
End Try


'////////////////////////////////////////
'////////////////////////////////////////
'////////////////////////////////////////
Print( "~n~ntest suite 2 - decoding" )
Local res$, res_r$, res_r2$, res_r3$, size%, size2%, size3%, element$

'////////////////////////////////////////
Print( "~ntest 2.1 - string value" )
Try
	jstr = "~qQuoth the raven, \~qNever more.\~q~q"
	Local str:Object = JSON.Decode( jstr )
	Print( jstr+" --> "+str.ToString() )
Catch ex$
	Print "Test FAILED with Exception: "+ex
End Try

'////////////////////////////////////////
Print( "~ntest 2.2 - integral value" )
Try
	jstr = "10487649"
	Local num_i:Object = JSON.Decode( jstr )
	Print( jstr+" --> "+num_i.ToString() )
Catch ex$
	Print "Test FAILED with Exception: "+ex
End Try

'////////////////////////////////////////
Print( "~ntest 2.3 - floating-point value" )
Try
	jstr = "0.0024786"
	Local num_fp:Object = JSON.Decode( jstr )
	Print( jstr+" --> "+num_fp.ToString() )
Catch ex$
	Print "Test FAILED with Exception: "+ex
End Try

'////////////////////////////////////////
Print( "~ntest 2.4 - boolean value" )
Try
	jstr = "true"
	Local bt:Object = JSON.Decode( jstr )
	Print( jstr+" --> "+bt.ToString() )
	jstr = "false"
	Local bf:Object = JSON.Decode( jstr )
	Print( jstr+" --> "+bf.ToString() )
Catch ex$
	Print "Test FAILED with Exception: "+ex
End Try

'////////////////////////////////////////
Print( "~ntest 2.5 - null value" )
Try
	jstr = "null"
	Local val:Object = JSON.Decode( jstr )
	If Not val Then res = "null" Else res = "not-null"
	Print( jstr+" --> "+res )
Catch ex$
	Print "Test FAILED with Exception: "+ex
End Try

'////////////////////////////////////////
Print( "~ntest 2.6 - int array" )
Try
	jstr = " [ 5,10,    15, 20 ] "
	Local ix:Int[]
	type_id = TTypeId.ForName("Int[]")
	ix = Int[](JSON.Decode( jstr,, type_id ))
	For Local i% = 0 Until ix.length
		If i = 0 Then res = String.FromInt( ix[i] ) Else res :+ String.FromInt( ix[i] )
		If i < ix.length - 1 Then res :+ ","
	Next
	res = "["+res+"]"
	Print( jstr+" --> "+res )
Catch ex$
	Print "Test FAILED with Exception: "+ex
End Try

'////////////////////////////////////////
Print( "~ntest 2.7 - simple object containing int array" )
Type ExampleIntContainer
	Field ix:Int[]
End Type
Try
	jstr = "{ ~qix~q: [ 0, 1, 2, 10, 20, 100, 5000 ] }"
	Local eic:ExampleIntContainer
	type_id = TTypeId.ForName("ExampleIntContainer")
	eic = ExampleIntContainer( JSON.Decode( jstr,, type_id ))
	For Local i% = 0 Until eic.ix.length
		If i = 0 Then res = String.FromInt( eic.ix[i] ) Else res :+ String.FromInt( eic.ix[i] )
		If i < eic.ix.length - 1 Then res :+ ","
	Next
	res = "["+res+"]"
	Print( jstr+" --> ExampleIntContainer("+eic.ToString()+"): ix="+res )
Catch ex$
	Print "Test FAILED with Exception: "+ex
End Try

'////////////////////////////////////////
Print( "~ntest 2.8 - simple object of arbitrary type" )
Try
	jstr = "  { ~qb~q : 250,~qa~q:5  , ~qc~q  :105} "
	Local eudt:ExampleUserDefinedType
	type_id = TTypeId.ForName("ExampleUserDefinedType")
	eudt = ExampleUserDefinedType( JSON.Decode( jstr,, type_id ))
	Print( jstr+" --> ExampleUserDefinedType("+eudt.ToString()+"): a="+eudt.a+", b="+eudt.b+", c="+eudt.c )
Catch ex$
	Print "Test FAILED with Exception: "+ex
End Try

'////////////////////////////////////////
Print( "~ntest 2.9 - object of arbitrary type" )
Try
	jstr = ..
	"{~qb~q:135,~qs~q:36700,~qi~q:1587492043,~ql~q:4958248718354,~qf~q:0.00004524,~qd~q:1498510.459,~qstr~q:~qHello,World!~q,"+..
	"~qbx~q:[12,23,135,3],~qsx~q:[1000,3000,5000,20400],~qix~q:[1475,192334,4952408],~qlx~q:[4498524,4198475049,8968763549],"+..
	"~qfx~q:[0.2498,0.004245,14356000.0],~qdx~q:[1.29854e24,1.4985,0.024587e-31],~qstrx~q:[~qHello1~q,~qHello2~q,~qHello3~q],"+..
	"~qo1str~q:~qString~q,~qo1x~q:[~qString1~q,~qString2~q,~qString3~q],~qo1udt~q:{~qa~q:50,~qb~q:100,~qc~q:150}}"
	Print( "encoded: "+jstr )
	Local ed:ExampleData
	type_id = TTypeId.ForName("ExampleData")
	ed = ExampleData( JSON.Decode( jstr,, type_id ))
	res = "ExampleData("+ed.ToString()+"):"
	res :+ "~n  "+"b = "+String.FromInt( ed.b )
	res :+ "~n  "+"s = "+String.FromInt( ed.s )
	res :+ "~n  "+"i = "+String.FromInt( ed.i )
	res :+ "~n  "+"l = "+String.FromLong( ed.l )
	res :+ "~n  "+"f = "+String.FromFloat( ed.f )
	res :+ "~n  "+"d = "+String.FromDouble( ed.d )
	res :+ "~n  "+"str = ~q"+ed.str+"~q"
	size = ed.bx.Length
	For Local i% = 0 Until size
		If i = 0 Then res_r = "["
		element = "" + ed.bx[i]
		res_r :+ element
		If i < (size - 1) Then res_r :+ "," Else If i = (size - 1) Then res_r :+ "]"
	Next
	res :+ "~n  "+"bx = "+res_r
	size = ed.sx.Length
	For Local i% = 0 Until size
		If i = 0 Then res_r = "["
		element = "" + ed.sx[i]
		res_r :+ element
		If i < (size - 1) Then res_r :+ "," Else If i = (size - 1) Then res_r :+ "]"
	Next
	res :+ "~n  "+"sx = "+res_r
	size = ed.ix.Length
	For Local i% = 0 Until size
		If i = 0 Then res_r = "["
		element = "" + ed.ix[i]
		res_r :+ element
		If i < (size - 1) Then res_r :+ "," Else If i = (size - 1) Then res_r :+ "]"
	Next
	res :+ "~n  "+"ix = "+res_r
	size = ed.lx.Length
	For Local i% = 0 Until size
		If i = 0 Then res_r = "["
		element = "" + ed.lx[i]
		res_r :+ element
		If i < (size - 1) Then res_r :+ "," Else If i = (size - 1) Then res_r :+ "]"
	Next
	res :+ "~n  "+"lx = "+res_r
	size = ed.fx.Length
	For Local i% = 0 Until size
		If i = 0 Then res_r = "["
		element = "" + ed.fx[i]
		res_r :+ element
		If i < (size - 1) Then res_r :+ "," Else If i = (size - 1) Then res_r :+ "]"
	Next
	res :+ "~n  "+"fx = "+res_r
	size = ed.dx.Length
	For Local i% = 0 Until size
		If i = 0 Then res_r = "["
		element = "" + ed.dx[i]
		res_r :+ element
		If i < (size - 1) Then res_r :+ "," Else If i = (size - 1) Then res_r :+ "]"
	Next
	res :+ "~n  "+"dx = "+res_r
	size = ed.strx.Length
	For Local i% = 0 Until size
		If i = 0 Then res_r = "["
		element = "~q" + ed.strx[i] + "~q"
		res_r :+ element
		If i < (size - 1) Then res_r :+ "," Else If i = (size - 1) Then res_r :+ "]"
	Next
	res :+ "~n  "+"strx = "+res_r
	res :+ "~n  "+"o1str = "+JSON.ObjectInfo(ed.o1str)
	res :+ "~n  "+"o1x = "+JSON.ObjectInfo(ed.o1x)
	res :+ "~n  "+"o1udt = "+JSON.ObjectInfo(ed.o1udt)
	Print( "decoded: "+res )
Catch ex$
	Print "Test FAILED with Exception: "+ex
End Try

'////////////////////////////////////////
Print( "~ntest 2.10 - nested objects of explicit type" )
'///
Type ExampleObject
	Field member:ExampleMemberObject
End Type
Type ExampleMemberObject
	Field value:Int
End Type
'///
Try
	jstr = "{~qmember~q:{~qvalue~q:500}}"
	type_id = TTypeId.ForName("ExampleObject")
	Local ex:ExampleObject = ExampleObject( JSON.Decode( jstr,, type_id ))
	Print( jstr+" --> JSON.Decode(ExampleObject) --> "+JSON.ObjectInfo(ex)+": member = "+JSON.ObjectInfo(ex.member) )
Catch ex$
	Print "Test FAILED with Exception: "+ex
End Try

'////////////////////////////////////////
Print( "~ntest 2.11 - TMap" )
Try
	jstr = "{~qkey1~q:5,~qkey2~q:[10,15,20]}"
	Local map:TMap = TMap( JSON.Decode( jstr,, TTypeId.ForName("TMap") ))
	Print "encoded: "+jstr
	Print "decoded: "+JSON.ObjectInfo(map)+..
	"~n  key1 = "+JSON.ObjectInfo(map.ValueForKey("key1"))+..
	"~n  key2 = "+JSON.ObjectInfo(map.ValueForKey("key2"))
Catch ex$
	Print "Test FAILED with Exception: "+ex
End Try

'////////////////////////////////////////
Print( "~ntest 2.12 - TList" )
Try
	
Catch ex$
	Print "Test FAILED with Exception: "+ex
End Try


'////////////////////////////////////////
Print( "~ntest 2.13 - int array array array" )
Try
	jstr = "[[[1,2],[4,8]],[[16,32],[64,128]]]"
	Local ixx:Int[][][] = Int[][][]( JSON.Decode( jstr,, TTypeId.ForName("Int[][][]") ))
	size = ixx.Length
	For Local i% = 0 Until size
		If i = 0 Then res_r = "["
		size2 = ixx[i].Length
		For Local j% = 0 Until size2
			If j = 0 Then res_r2 = "["
			size3 = ixx[i][j].Length
			For Local k% = 0 Until size3
				If k = 0 Then res_r3 = "["
				res_r3 :+ ixx[i][j][k]
				If k < (size3 - 1) Then res_r3 :+ "," ..
				Else If k = (size3 - 1) Then res_r3 :+ "]"
			Next
			res_r2 :+ res_r3
			If j < (size2 - 1) Then res_r2 :+ "," ..
			Else If j = (size2 - 1) Then res_r2 :+ "]"
		Next
		res_r :+ res_r2
		If i < (size - 1) Then res_r :+ "," ..
		Else If i = (size - 1) Then res_r :+ "]"
	Next
	Print jstr+" ---> "+res_r
Catch ex$
	Print "Test FAILED with Exception: "+ex
End Try

'////////////////////////////////////////
Print( "~ntest 2.13 - multidimensional int array" )
Try
	jstr = "[[[1,2],[4,8]],[[16,32],[64,128]]]"
	Local ix2:Int[,,]
	type_id = IntTypeId.ArrayType( 3 )
	ix2 = Int[,,]( JSON.Decode( jstr,, type_id ))
	res_r = ""
	size = ix2.Length
	Local dims:Int[] = ix2.Dimensions()
	'Local c:Int[] = New Int[dims.Length]
	'Local dim_size%
	For Local i% = 0 Until size
		For Local d% = EachIn dims
			'If d = (d-1) Then dim_size = size Else dim_size = dims[d] / dims[d+1]
			'c[d] = i Mod dim_size
			If i Mod d = 0 Then res_r :+ "["
		Next
		res_r :+ type_id.GetArrayElement( ix2, i ).ToString() 'ix2[c[0],c[1],c[2]]
		For Local d% = EachIn dims
			If (i+1) Mod d = 0 Then res_r :+ "]"
		Next
		If i < (size-1) Then res_r :+ ","
	Next
	Print jstr+" ---> "+res_r
Catch ex$
	Print "Test FAILED with Exception: "+ex
End Try

'////////////////////////////////////////
'////////////////////////////////////////
'////////////////////////////////////////
Print( "~n~ntest suite 3 - round trip" )

'////////////////////////////////////////
Print( "~ntest 3.1 - int array" )
Try
	Local ar_int:Int[] = [ 0, 2, 4, 8, 16, 32, 64 ]
	For Local i% = 0 Until ar_int.length
		If i = 0 Then res = String.FromInt( ar_int[i] ) Else res :+ String.FromInt( ar_int[i] )
		If i < ar_int.length - 1 Then res :+ ","
	Next
	res = "["+res+"]"
	Print( "object:  "+res )
	'///
	settings.pretty_print = False
	jstr = JSON.Encode( ar_int, settings )
	Print( "encoded: "+jstr )
	'///
	Local d_int:Int[] = Int[]( JSON.Decode( jstr,, TTypeId.ForName("Int[]") ))
	For Local i% = 0 Until d_int.length
		If i = 0 Then res = String.FromInt( d_int[i] ) Else res :+ String.FromInt( d_int[i] )
		If i < d_int.length - 1 Then res :+ ","
	Next
	res = "["+res+"]"
	Print( "decoded: "+res )
Catch ex$
	Print "Test FAILED with Exception: "+ex
End Try


'////////////////////////////////////////
'////////////////////////////////////////
'////////////////////////////////////////
Print( "~n~ntest suite 4 - negative testing" )

'////////////////////////////////////////
Print( "~ntest 4.1 - attempt to decode a string array into an int array" )
jstr = "[~qstring1~q,~qstring2~q,~qstring3~q]"
Print "encoded: "+jstr
Local int_arr:Int[]
Try
	int_arr = Int[]( JSON.Decode( jstr,, TTypeId.ForName("Int[]") ))
	size = int_arr.Length
	For Local i% = 0 Until size
		If i = 0 Then res_r = "["
		element = "" + int_arr[i]
		res_r :+ element
		If i < (size - 1) Then res_r :+ "," Else If i = (size - 1) Then res_r :+ "]"
	Next
	Print "decoded: "+res_r
	Print "Negative Test FAILED; exception was anticipated"
Catch ex$
	Print "Anticipated Exception: "+ex
End Try

'////////////////////////////////////////
Print( "~ntest 4.2 - decoding (JSON object.member:string) into (BMX Type.Field:Int)" )
Try
	jstr = "{~qvalue~q:~qString Value!~q}"
	Local obj:ExampleMemberObject = ExampleMemberObject( JSON.Decode( jstr,, TTypeId.ForName("ExampleMemberObject") ))
	Print "Negative Test FAILED; exception was anticipated"
Catch ex$
	Print "Anticipated Exception: "+ex
End Try

'////////////////////////////////////////
Print( "~ntest 4.3 - JSON object.member found with no corresponding BMX given Type.Field" )
Try
	jstr = "{~qgarbage_member_name~q:~qString Value!~q}"
	Local obj:ExampleMemberObject = ExampleMemberObject( JSON.Decode( jstr,, TTypeId.ForName("ExampleMemberObject") ))
	Print "Negative Test FAILED; exception was anticipated"
Catch ex$
	Print "Anticipated Exception: "+ex
End Try

'////////////////////////////////////////
'////////////////////////////////////////
'////////////////////////////////////////
Print( "~n~ntest suite 5 - field mapping" )

'////////////////////////////////////////
Print( "~ntest 5.1 - encode an object with some fields renamed" )
Try
	udt.a = 1
	udt.b = 2
	udt.c = 3
	settings = New TJSONEncodeSettings
	settings.OverrideFieldName( TTypeId.ForName( "ExampleUserDefinedType" ), "a", "type" )
	jstr = JSON.Encode( udt, settings );
	Print( jstr )
Catch ex$
	Print "Test FAILED: "+ex
End Try

'////////////////////////////////////////
Print( "~ntest 5.2 - round trip; decode the object from test 5.1, with fields renamed back to the original names" )
Try
	udt = ExampleUserDefinedType( JSON.Decode( jstr,, TTypeId.ForName("ExampleUserDefinedType") ))
Catch ex$
	Print "Test FAILED: "+ex
End Try


