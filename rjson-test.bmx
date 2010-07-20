' test suite for bmx-rjson
SuperStrict
Import twrc.rjson
'Import "rjson.bmx"

Try

'////////////////////////////////////////
'////////////////////////////////////////
'////////////////////////////////////////
Print( "~n~ntest suite 0 - wrapper types" )

'////////////////////////////////////////
Print( "~ntest 0.1 - null - Null" )
Print JSON.Encode( Null )

'////////////////////////////////////////
Print( "~ntest 0.2 - boolean - JSON only" )
Local b:TJSONBoolean
b = TJSONBoolean.Create( True )
Print JSON.Encode( b )
b = TJSONBoolean.Create( False )
Print JSON.Encode( b )

'////////////////////////////////////////
Print( "~ntest 0.3 - number - (Byte/Short/Int/Long)" )
Local nl:TJSONLong
nl = TJSONLong.Create( Byte(85) )
Print JSON.Encode( nl )
nl = TJSONLong.Create( Short(85) )
Print JSON.Encode( nl )
nl = TJSONLong.Create( Int(85) )
Print JSON.Encode( nl )
nl = TJSONLong.Create( Long(85) )
Print JSON.Encode( nl )

'////////////////////////////////////////
Print( "~ntest 0.4 - number - (Float/Double)" )
Local nd:TJSONDouble
nd = TJSONDouble.Create( Float(85.1) )
Print JSON.Encode( nd )
nd = TJSONDouble.Create( Double(85.1) )
Print JSON.Encode( nd )


'////////////////////////////////////////
'////////////////////////////////////////
'////////////////////////////////////////
Print( "~n~ntest suite 1 - encoding" )
Local encoded_json_string:String
Local settings:TJSONEncodeSettings = New TJSONEncodeSettings
Local typeId:TTypeId

'////////////////////////////////////////
Print( "~ntest 1.1 - int array" )
Local arr_i:Int[] = [ 1, 2, 3, 40, 41, 42, 101 ]
'///
settings.pretty_print = False
Print( "  -pretty_print" )
encoded_json_string = JSON.Encode( arr_i, settings )
Print( encoded_json_string )
'///
settings.pretty_print = True
Print( "  +pretty_print" )
encoded_json_string = JSON.Encode( arr_i, settings )
Print( encoded_json_string )

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
Local ex_d:ExampleData = New ExampleData
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
encoded_json_string = JSON.Encode( ex_d, settings )
Print( encoded_json_string )
'///
settings.pretty_print = True
Print( "  +pretty_print" )
encoded_json_string = JSON.Encode( ex_d, settings )
Print( encoded_json_string )

'////////////////////////////////////////
Print( "~ntest 1.2b: +ignoreFields( l, f, d, strx )" )
typeId = TTypeId.ForName("ExampleData")
settings.IgnoreField( typeId, typeId.FindField("l") )
settings.IgnoreField( typeId, typeId.FindField("f") )
settings.IgnoreField( typeId, typeId.FindField("d") )
settings.IgnoreField( typeId, typeId.FindField("strx") )
encoded_json_string = JSON.Encode( ex_d, settings )
Print( encoded_json_string )
settings:TJSONEncodeSettings = New TJSONEncodeSettings

'////////////////////////////////////////
Print( "~ntest 1.3 - array of arrays" )
Local arr_arr_i:Int[][][] = [ [ [ 0, 1 ], [ 2, 3 ] ], [ [ 4, 5 ], [ 6, 7 ] ] ]
'///
settings.pretty_print = False
Print( "  -pretty_print" )
encoded_json_string = JSON.Encode( arr_arr_i, settings )
Print( encoded_json_string )
'///
settings.pretty_print = True
Print( "  +pretty_print" )
encoded_json_string = JSON.Encode( arr_arr_i, settings )
Print( encoded_json_string )

'////////////////////////////////////////
Print( "~ntest 1.4 - multi-dimensional array" )
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
encoded_json_string = JSON.Encode( arr2d_i, settings )
Print( encoded_json_string )
'///
settings.pretty_print = True
Print( "  +pretty_print" )
encoded_json_string = JSON.Encode( arr2d_i, settings )
Print( encoded_json_string )

'////////////////////////////////////////
Print( "~ntest 1.5 - TList" )
Local ls:TList = CreateList()
ls.AddLast( "String Value!" )
ls.AddLast( [ 0, 1, 2, 4, 8 ] )
ls.AddLast( CreateList() )
ls.AddLast( New Int[0] )
ls.AddLast( TJSONDouble.Create( 0.004824146 ))
ls.AddLast( TJSONLong.Create( 4257481243 ))
ls.AddLast( TJSONBoolean.Create( True ))
'///
settings.pretty_print = False
Print( "  -pretty_print" )
encoded_json_string = JSON.Encode( ls, settings )
Print( encoded_json_string )
'///
settings.pretty_print = True
Print( "  +pretty_print" )
encoded_json_string = JSON.Encode( ls, settings )
Print( encoded_json_string )

'////////////////////////////////////////
Print( "~ntest 1.6 - TMap" )
Local mp:TMap = CreateMap()
mp.Insert( "key1", "String Value!" )
mp.Insert( "key2", [ 0, 1, 2, 4, 8 ] )
mp.Insert( "key3", CreateList() )
mp.Insert( "key4", New Int[0] )
mp.Insert( "key5", TJSONDouble.Create( 0.004824146 ))
mp.Insert( "key6", TJSONLong.Create( 4257481243 ))
mp.Insert( "key7", TJSONBoolean.Create( True ))
'///
settings.pretty_print = False
Print( "  -pretty_print" )
encoded_json_string = JSON.Encode( mp, settings )
Print( encoded_json_string )
'///
settings.pretty_print = True
Print( "  +pretty_print" )
encoded_json_string = JSON.Encode( mp, settings )
Print( encoded_json_string )


'////////////////////////////////////////
'////////////////////////////////////////
'////////////////////////////////////////
Print( "~n~ntest suite 2 - decoding" )
Local res$, res_r$, size%, element$

'////////////////////////////////////////
Print( "~ntest 2.1 - string value" )
encoded_json_string = "~qQuoth the raven, \~qNever more.\~q~q"
Local str:Object = JSON.Decode( encoded_json_string )
Print( encoded_json_string+" --> "+str.ToString() )

'////////////////////////////////////////
Print( "~ntest 2.2 - integral value" )
encoded_json_string = "10487649"
Local num_i:Object = JSON.Decode( encoded_json_string )
Print( encoded_json_string+" --> "+num_i.ToString() )

'////////////////////////////////////////
Print( "~ntest 2.3 - floating-point value" )
encoded_json_string = "0.0024786"
Local num_fp:Object = JSON.Decode( encoded_json_string )
Print( encoded_json_string+" --> "+num_fp.ToString() )

'////////////////////////////////////////
Print( "~ntest 2.4 - boolean value" )
encoded_json_string = "true"
Local bt:Object = JSON.Decode( encoded_json_string )
Print( encoded_json_string+" --> "+bt.ToString() )
encoded_json_string = "false"
Local bf:Object = JSON.Decode( encoded_json_string )
Print( encoded_json_string+" --> "+bf.ToString() )

'////////////////////////////////////////
Print( "~ntest 2.5 - null value" )
encoded_json_string = "null"
Local val:Object = JSON.Decode( encoded_json_string )
If Not val Then res = "null" Else res = "not-null"
Print( encoded_json_string+" --> "+res )

'////////////////////////////////////////
Print( "~ntest 2.6 - int array" )
encoded_json_string = " [ 5,10,    15, 20 ] "
Local ix:Int[]
typeId = TTypeId.ForName("Int[]")
ix = Int[](JSON.Decode( encoded_json_string, typeId ))
For Local i% = 0 Until ix.length
	If i = 0 Then res = String.FromInt( ix[i] ) Else res :+ String.FromInt( ix[i] )
	If i < ix.length - 1 Then res :+ ","
Next
res = "["+res+"]"
Print( encoded_json_string+" --> "+res )

'////////////////////////////////////////
Print( "~ntest 2.7 - simple object containing int array" )
Type ExampleIntContainer
	Field ix:Int[]
End Type
encoded_json_string = "{ ~qix~q: [ 0, 1, 2, 10, 20, 100, 5000 ] }"
Local eic:ExampleIntContainer
typeId = TTypeId.ForName("ExampleIntContainer")
eic = ExampleIntContainer( JSON.Decode( encoded_json_string, typeId ))
For Local i% = 0 Until eic.ix.length
	If i = 0 Then res = String.FromInt( eic.ix[i] ) Else res :+ String.FromInt( eic.ix[i] )
	If i < eic.ix.length - 1 Then res :+ ","
Next
res = "["+res+"]"
Print( encoded_json_string+" --> ExampleIntContainer("+eic.ToString()+"): ix="+res )

'////////////////////////////////////////
Print( "~ntest 2.8 - simple object of arbitrary type" )
encoded_json_string = "  { ~qb~q : 250,~qa~q:5  , ~qc~q  :105} "
Local eudt:ExampleUserDefinedType
typeId = TTypeId.ForName("ExampleUserDefinedType")
eudt = ExampleUserDefinedType( JSON.Decode( encoded_json_string, typeId ))
Print( encoded_json_string+" --> ExampleUserDefinedType("+eudt.ToString()+"): a="+eudt.a+", b="+eudt.b+", c="+eudt.c )

'////////////////////////////////////////
Print( "~ntest 2.9 - object of arbitrary type" )
encoded_json_string = ..
"{~qb~q:135,~qs~q:36700,~qi~q:1587492043,~ql~q:4958248718354,~qf~q:0.00004524,~qd~q:1498510.459,~qstr~q:~qHello,World!~q,"+..
"~qbx~q:[12,23,135,3],~qsx~q:[1000,3000,5000,20400],~qix~q:[1475,192334,4952408],~qlx~q:[4498524,4198475049,8968763549],"+..
"~qfx~q:[0.2498,0.004245,14356000.0],~qdx~q:[1.29854e24,1.4985,0.024587e-31],~qstrx~q:[~qHello1~q,~qHello2~q,~qHello3~q],"+..
"~qo1str~q:~qString~q,~qo1x~q:[~qString1~q,~qString2~q,~qString3~q],~qo1udt~q:{~qa~q:50,~qb~q:100,~qc~q:150}}"
Print( "encoded: "+encoded_json_string )
Local ed:ExampleData
typeId = TTypeId.ForName("ExampleData")
ed = ExampleData( JSON.Decode( encoded_json_string, typeId ))
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

'////////////////////////////////////////
Print( "~ntest 2.10 - nested objects of explicit type" )
Type ExampleObject
	Field member:ExampleMemberObject
End Type
Type ExampleMemberObject
	Field value:Int
End Type
encoded_json_string = "{~qmember~q:{~qvalue~q:500}}"
typeId = TTypeId.ForName("ExampleObject")
Local ex:ExampleObject = ExampleObject( JSON.Decode( encoded_json_string, typeId ))
Print( encoded_json_string+" --> JSON.Decode(ExampleObject) --> "+JSON.ObjectInfo(ex)+": member = "+JSON.ObjectInfo(ex.member) )


'////////////////////////////////////////
'////////////////////////////////////////
'////////////////////////////////////////
Print( "~n~ntest suite 3 - round trip" )

'////////////////////////////////////////
Print( "~ntest 3.1 - int array" )
Local ar_int:Int[] = [ 0, 2, 4, 8, 16, 32, 64 ]
For Local i% = 0 Until ar_int.length
	If i = 0 Then res = String.FromInt( ar_int[i] ) Else res :+ String.FromInt( ar_int[i] )
	If i < ar_int.length - 1 Then res :+ ","
Next
res = "["+res+"]"
Print( "object:  "+res )
'///
settings.pretty_print = False
encoded_json_string = JSON.Encode( ar_int, settings )
Print( "encoded: "+encoded_json_string )
'///
Local d_int:Int[] = Int[]( JSON.Decode( encoded_json_string, TTypeId.ForName("Int[]") ))
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
'Print( "~n~ntest suite 4 - negative testing" )

'////////////////////////////////////////
'Print( "~ntest 4.1 - decoding with incompatible type" )




