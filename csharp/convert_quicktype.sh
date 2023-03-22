#!/bin/sh


vi \
-c ":%s/Ignore)]\n\( *\)public \([^ ]\+\)\([^?]\) /Ignore)]\r\1public \2\3? /g"  \
-c ":%s/DisallowNull/Default/g" \
-c ":%s/namespace /#nullable enable\r#pragma warning disable 8618\rnamespace /g" \
-c ":%s/public static \(.\+\) FromJson(string json) \+=> \+JsonConvert.DeserializeObject<\(.*\)>(json, \(\w\+.\+\).Converter.Settings);/public static \1? FromJson(string json)\r        {\r            try { return JsonConvert.DeserializeObject<\1>(json, \3.Converter.Settings); } catch (System.Exception e) {\r#if UNITY_EDITOR || UNITY_STANDALONE ||UNITY_IOS || UNITY_ANDROID || UNITY_WSA || UNITY_WEBGL\r                UnityEngine.Debug.LogError(e);\r\r                UnityEngine.Debug.LogError(\"error json str: \" + json);\r#else\r                System.Console.Error.WriteLine(e);\r                System.Console.Error.WriteLine(\"error json str: \" + json);\r#endif\r                return null;\r            }\r        }/g" \
-c ":%s/public static \(.\+\) FromJsonArray(string json) \+=> \+JsonConvert.DeserializeObject<\(.*\)>(json, \(\w\+.\+\).Converter.Settings);/public static \1? FromJsonArray(string json)\r        {\r            try { return JsonConvert.DeserializeObject<\1>(json, \3.Converter.Settings); } catch (System.Exception e) {\r#if UNITY_EDITOR || UNITY_STANDALONE ||UNITY_IOS || UNITY_ANDROID || UNITY_WSA || UNITY_WEBGL\r                UnityEngine.Debug.LogError(e);\r#else\r                System.Console.Error.WriteLine(e);\r#endif\r                return null;\r            }\r        }/g" \
"+wq" $1
