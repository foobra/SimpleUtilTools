#!/bin/sh


vi -c ":%s/Ignore)]\n\( *\)public \(\w\+\)\([^?]\) /Ignore)]\r\1public \2\3? /g"  \
-c ":%s/DisallowNull/Default/g" \
-c ":%s/namespace QuickType/#nullable enable\r#pragma warning disable 8618\rnamespace QuickType/g" \
-c "%s/using Newtonsoft.Json.Converters;/using Newtonsoft.Json.Converters;\r static class Detail\r {\r public static Object? HandleJsonException(JsonException e)\r {\r #if UNITY_EDITOR || UNITY_STANDALONE || UNITY_IOS  || UNITY_ANDROID || UNITY_WSA || UNITY_WEBGL\r UnityEngine.Debug.LogError(e);\r UnityEngine.Debug.Break();\r #else\r System.Console.Error.WriteLine(e);\r System.Diagnostics.Debugger.Break();\r #endif\r return null;\r }\r }/g" \
-c "%s/public static \(\w\+\) FromJson(string json) => JsonConvert.DeserializeObject<\(\w\+\)>(json, QuickType.Converter.Settings);/public static \1? FromJson(string json)\r        {\r            try { return JsonConvert.DeserializeObject<\1>(json, Converter.Settings); } catch (JsonException e) { return (\1?)Detail.HandleJsonException(e); }\r        }/g" \
-c "%s/public static \(\w\+\) ToJson(this \(\w\+\) self) => JsonConvert.SerializeObject(self, QuickType.Converter.Settings);/public static \1? ToJson(this \2 self)\r        {\r            try { return JsonConvert.SerializeObject(self, QuickType.Converter.Settings); } catch (JsonException e) { return (\1?)Detail.HandleJsonException(e); }\r        }/g" \
"+wq" $1


