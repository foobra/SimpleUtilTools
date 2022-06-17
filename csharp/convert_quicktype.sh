#!/bin/sh


vi \
-c ":%s/Ignore)]\n\( *\)public \(\w\+\)\([^?]\) /Ignore)]\r\1public \2\3? /g"  \
-c ":%s/DisallowNull/Default/g" \
-c ":%s/namespace /#nullable enable\r#pragma warning disable 8618\rnamespace /g" \
-c ":%s/using Newtonsoft.Json.Converters;/using Newtonsoft.Json.Converters;\r    static class Detail\r    {\r        public static Object? HandleJsonException(JsonException e)\r        {\r            #if UNITY_EDITOR || UNITY_STANDALONE || UNITY_IOS  || UNITY_ANDROID || UNITY_WSA || UNITY_WEBGL\r                UnityEngine.Debug.LogError(e);\r                UnityEngine.Debug.Break();\r            #else\r                System.Console.Error.WriteLine(e);\r                System.Diagnostics.Debugger.Break();\r            #endif\r            return null;\r        }\r    }/g" \
-c ":%s/public static \(\w\+\[*\]*\) FromJson(string json) => JsonConvert.DeserializeObject<\w\+\[*\]*>(json, \(\w\+\).Converter.Settings);/public static \1? FromJson(string json)\r        {\r            try { return JsonConvert.DeserializeObject<\1>(json, \2.Converter.Settings); } catch (JsonException e) { return (\1?)Detail.HandleJsonException(e); }\r        }/g" \
"+wq" $1


# -c "%s/public static string ToJson(this \((\w|\[|])\+\) self) => JsonConvert.SerializeObject(self, \(\w\+\).Converter.Settings);/public static string ToJson(this \1 self)\r        {\r            try { return JsonConvert.SerializeObject(self, \2.Converter.Settings); } catch (JsonException e) { return (\1?)Detail.HandleJsonException(e); }\r        }/g" \


