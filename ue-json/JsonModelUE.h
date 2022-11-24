// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "Serialization/JsonSerializer.h"
#include "Dom/JsonObject.h"

#include "JsonModelUE.generated.h"

using JsonWriter = TSharedRef<TJsonWriter<>>;

UCLASS(BlueprintType)
class MIGUAVATARJSON_API UJsonModelUE : public UObject
{
  GENERATED_BODY()
public:
	virtual void WriteJson(JsonWriter& Writer) const {};
	virtual bool FromJson(const TSharedPtr<FJsonValue>& JsonValue){ return false;};
};
