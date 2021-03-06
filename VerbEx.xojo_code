#tag Class
 Attributes ( Author = "Vaughn S. Cordero" ) Protected Class VerbEx
Inherits RegEx
Implements VerbalExpressionsInterface
	#tag Method, Flags = &h21, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit))
		Private Function Add(value as Variant) As VerbEx
		  //some implementations accept Add() to 'recompile' the expression
		  
		  if value.IsNull or value.StringValue="" Then
		    dim err as new UnsupportedOperationException
		    err.Message="Add requires a value"
		    raise err
		  end
		  
		  me.SearchPattern=me.SearchPattern+value
		  return me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Any(value as String) As VerbEx
		  return me.AnyOf(Sanitize(value))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function AnyOf(value as String) As VerbEx
		  return me.Add("(?:[" + Sanitize(value) + "])")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Anything() As verbex
		  return me.add("(?:.*)")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function AnythingBut(value as string) As Verbex
		  return me.add("(?:[^" + Sanitize(value) + "]*)")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function br() As VerbEx
		  return me.LineBreak
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Digit() As VerbEx
		  return me.add(DigitToken)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function EndCapture() As VerbEx
		  return me.Add(")")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function EndOfLine() As VerbEx
		  return me.Add("$")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Escape(value as variant) As String
		  const reserved="[\].|*?+(){}^$\\:=[]"
		  dim escape as new regex
		  escape.SearchPattern="("+reserved+")"
		  escape.Options.Greedy=true
		  escape.ReplacementPattern="\\$&"
		  Return escape.Replace(value)
		  
		  //PCRE
		  // .^$*+?()[{\|
		  // and these inside character classes:
		  // ^-]\
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Find(value as String) As VerbEx
		  return me.Add ("(?:"+Sanitize(value)+")")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LineBreak() As VerbEx
		  //this may be academic, as RegExOptions.LineEndType defaults to any ending
		  return me.add("(?:(?:\n)|(?:\r\n))")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Matches(target as String) As Variant
		  Match=Search(target)
		  try
		    return Match.SubExpressionCount
		  catch
		    Return False
		  end
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Maybe(value as String) As VerbEx
		  return me.Find(Sanitize(value)).Add("?")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Multiple(paramarray counts as variant) As VerbEx
		  //should allow [value][exact|min][max]
		  
		  dim value as Variant=nil
		  dim suffix as String="*"
		  
		  try
		    value=counts(0)
		  catch OutOfBoundsException
		    return me.Add(suffix) //applies to previous item
		  end
		  
		  if value.Type=Variant.TypeString then
		    value="["+Sanitize(value)+"]"
		    counts.remove(0)
		  end
		  
		  //treat anything else as numeric
		  
		  for each number as Variant in counts
		    suffix=suffix+","+str(number.IntegerValue)
		  next
		  suffix=suffix.Replace("*","").replace(",","{")+"}"
		  
		  return me.Add(value+suffix)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OneOrMore(value as string) As VerbEx
		  return me.Add("["+Sanitize(value)+"]+")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Operator_Convert() As String
		  Return me.ToString
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Attributes( Alias = "Or" )  Function Or_(value as string) As VerbEx
		  return me.Add(" | ")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Replace(source as string, value as String) As String
		  // Per example at https://github.com/VerbalExpressions/PHPVerbalExpressions/wiki/.then(-value-)
		  dim limit as Boolean=me.Options.ReplaceAllMatches
		  if me.SearchPattern.Len>0 then
		    me.Options.ReplaceAllMatches=true
		    me.ReplacementPattern=Sanitize(value)
		    dim result as string=me.Replace(source)
		    me.Options.ReplaceAllMatches=limit
		    return result
		  end
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Sanitize(value as Variant) As String
		  if value.IsNull or value.StringValue="" then
		    
		    raise new NilObjectException
		    
		  end
		  
		  return escape(value)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function searchOneLine(value as boolean) As VerbEx
		  me.Options.TreatTargetAsOneLine=not value
		  
		  return me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Something() As VerbEx
		  return me.add("(?:.+)")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SomethingBut(value as String) As VerbEx
		  return me.add("(?:[^" + Sanitize(value) + "]+)")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StartCapture() As Verbex
		  return me.add("(")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StartOfLine() As VerbEx
		  'me.SearchPattern="^"+me.SearchPattern
		  Return me.Add("^")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Attributes( Convenience )  Function StartsWith(value as String) As VerbEx
		  return me.Add(StartOfLine).add(Sanitize(value))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StopAtFirst(value as Boolean) As VerbEx
		  me.Options.Greedy=not value
		  
		  exit
		  
		  //second option after subexpression (toggle)
		  if value<>me.Options.Greedy then
		    return me.add("?")
		  end
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function tab() As VerbEx
		  return me.add(TabToken)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Attributes( Alias = "Then" )  Function Then_(value as Variant) As Verbex
		  return me.add(Sanitize(value))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToString() As String
		  return me.SearchPattern
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Whitespace() As VerbEx
		  return me.add(WhitespaceToken)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function withAnyCase(value as Boolean = true) As VerbEx
		  me.Options.CaseSensitive=not value
		  return me
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Word() As VerbEx
		  return me.Add(WordToken)
		End Function
	#tag EndMethod


	#tag Note, Name = VerbEx Notes
		Initial work Vaughn S. Cordero 25 December 2017
		This note added 22 January 2018
		Please keep this note in the class and append any modifications separately.
		
		Xojo implmentation of VerbalExpressions as described at:
		https://github.com/VerbalExpressions/implementation/wiki/List-of-methods-to-implement
		
		Required methods noted in VerbalExpressionsInterface.
		Note that Then and Or are Xojo reserved words: Then_ and Or_ are used instead.
		
		Basic usage: Subclassed from Regex, so instatiate wherever you would use a regex
		and build your expression:
		
		me.Expression=new VerbEx
		me.Expression=me.Expression.StartOfLine.Then_("http").Maybe("s").Then_("://")_
		.Maybe("www").AnythingBut(" ").EndOfLine
		
		"StartsWith" is a convenience method to demonstrate how syntactic sugar can be added,
		combining 'StartOfLine' and 'Then(value)'
		
		"Matches" is a convenience method that returns a Variant, which can be used as Boolean or to get the actual number of matches:
		
		If verbex.matches then...
		  Select case verbex.Matches
		  Case 1
		  …
		  Case 2
		  …
		  End
		End
		
		VerbEx also exposes Regex.SearchPattern with both VerbEx.ToString and VerbEx.Operator_Convert As String if you want to access the 'built' regular expression.
		In the sample, this is used to show the radio button tooltips.
		N.B. It does not output RegExOptions prefixes/suffixes in the built string.
		
		A simple app with three test scenarios was included with this class.
	#tag EndNote


	#tag Property, Flags = &h0
		Match As RegExMatch
	#tag EndProperty


	#tag Constant, Name = CarriageReturnToken, Type = String, Dynamic = False, Default = \"\\r", Scope = Public
	#tag EndConstant

	#tag Constant, Name = DigitToken, Type = String, Dynamic = False, Default = \"\\d", Scope = Public
	#tag EndConstant

	#tag Constant, Name = LineFeedToken, Type = String, Dynamic = False, Default = \"\\n", Scope = Public
	#tag EndConstant

	#tag Constant, Name = TabToken, Type = String, Dynamic = False, Default = \"\\t", Scope = Public
	#tag EndConstant

	#tag Constant, Name = WhitespaceToken, Type = String, Dynamic = False, Default = \"\\s", Scope = Public
	#tag EndConstant

	#tag Constant, Name = WordToken, Type = String, Dynamic = False, Default = \"\\w+", Scope = Public
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Options"
			Visible=true
			Type="RegExOptions"
			EditorType="RegExOptions"
		#tag EndViewProperty
		#tag ViewProperty
			Name="prefixes"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ReplacementPattern"
			Visible=true
			Type="String"
			EditorType="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="SearchPattern"
			Visible=true
			Type="String"
			EditorType="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="SearchStartPosition"
			Visible=true
			Type="Integer"
			EditorType="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="suffixes"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
