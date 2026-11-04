# Chat C - C8/C9 staging reads only. All non-GET operations are pending manual tests. Windows PowerShell 5.1.
[CmdletBinding()]
param([switch]$LoadFunctionsOnly)
Set-StrictMode -Version 2
$ErrorActionPreference='Stop'
$script:C8Base='https://nixflex-voice-engine-staging.up.railway.app'
$script:Cases=@'
[
  {
    "number": 13,
    "method": "GET",
    "path": "/v1/integrations/calcom/number/:phoneNumber",
    "query": "",
    "schema": {
      "type": "object",
      "properties": {
        "phone_number": {
          "type": "string",
          "description": "Owned phone number."
        },
        "is_active": {
          "type": "boolean",
          "description": "Whether the saved integration is enabled."
        },
        "username": {
          "type": "string",
          "description": "Saved username or empty string."
        },
        "event_slug": {
          "type": "string",
          "description": "Saved event slug or empty string."
        },
        "default_timezone": {
          "type": "string",
          "description": "Saved time zone or empty string."
        },
        "api_key_set": {
          "type": "boolean",
          "description": "A calendar credential is configured; never the credential itself."
        }
      },
      "required": [
        "phone_number",
        "is_active",
        "username",
        "event_slug",
        "default_timezone",
        "api_key_set"
      ],
      "additionalProperties": false,
      "description": ""
    }
  },
  {
    "number": 16,
    "method": "GET",
    "path": "/v1/integrations/slack/number/:phoneNumber",
    "query": "",
    "schema": {
      "type": "object",
      "properties": {
        "phone_number": {
          "type": "string",
          "description": "Owned phone number."
        },
        "is_active": {
          "type": "boolean",
          "description": "Whether the saved integration is enabled."
        },
        "webhook_url_set": {
          "type": "boolean",
          "description": "An incoming webhook is configured."
        }
      },
      "required": [
        "phone_number",
        "is_active",
        "webhook_url_set"
      ],
      "additionalProperties": false,
      "description": ""
    }
  },
  {
    "number": 19,
    "method": "GET",
    "path": "/v1/integrations/zapier/number/:phoneNumber",
    "query": "",
    "schema": {
      "type": "object",
      "properties": {
        "phone_number": {
          "type": "string",
          "description": "Owned phone number."
        },
        "is_active": {
          "type": "boolean",
          "description": "Whether the saved integration is enabled."
        },
        "post_call_url_set": {
          "type": "boolean",
          "description": "A post-call destination is configured."
        }
      },
      "required": [
        "phone_number",
        "is_active",
        "post_call_url_set"
      ],
      "additionalProperties": false,
      "description": ""
    }
  },
  {
    "number": 22,
    "method": "GET",
    "path": "/v1/integrations/make/number/:phoneNumber",
    "query": "",
    "schema": {
      "type": "object",
      "properties": {
        "phone_number": {
          "type": "string",
          "description": "Owned phone number."
        },
        "is_active": {
          "type": "boolean",
          "description": "Whether the saved integration is enabled."
        },
        "post_call_url_set": {
          "type": "boolean",
          "description": "A post-call URL is saved."
        },
        "in_call_url_set": {
          "type": "boolean",
          "description": "An in-call URL is saved."
        },
        "tool_name": {
          "type": [
            "string",
            "null"
          ],
          "description": "Saved tool name."
        },
        "tool_description": {
          "type": [
            "string",
            "null"
          ],
          "description": "Saved tool description."
        },
        "parameters": {
          "type": [
            "object",
            "null"
          ],
          "additionalProperties": true,
          "description": "JSON object; nested properties are supplied by your integration."
        }
      },
      "required": [
        "phone_number",
        "is_active",
        "post_call_url_set",
        "in_call_url_set",
        "tool_name",
        "tool_description",
        "parameters"
      ],
      "additionalProperties": false,
      "description": ""
    }
  },
  {
    "number": 25,
    "method": "GET",
    "path": "/v1/integrations/gohighlevel/number/:phoneNumber",
    "query": "",
    "schema": {
      "type": "object",
      "properties": {
        "phone_number": {
          "type": "string",
          "description": "Owned phone number."
        },
        "is_active": {
          "type": "boolean",
          "description": "Whether the saved integration is enabled."
        },
        "pit_set": {
          "type": "boolean",
          "description": "A private token is configured."
        },
        "location_id": {
          "type": "string",
          "description": "Saved location ID or empty string."
        },
        "tags": {
          "type": "array",
          "items": {
            "type": "string",
            "description": "Saved tag."
          },
          "description": ""
        }
      },
      "required": [
        "phone_number",
        "is_active",
        "pit_set",
        "location_id",
        "tags"
      ],
      "additionalProperties": false,
      "description": ""
    }
  },
  {
    "number": 28,
    "method": "GET",
    "path": "/v1/integrations/webhook/number/:phoneNumber",
    "query": "",
    "schema": {
      "type": "object",
      "properties": {
        "phone_number": {
          "type": "string",
          "description": "Owned phone number."
        },
        "webhook_url": {
          "type": [
            "string",
            "null"
          ],
          "description": "Saved URL or null. Treat destination URLs as private."
        },
        "is_set": {
          "type": "boolean",
          "description": "A URL is saved at this exact level; does not resolve inheritance."
        }
      },
      "required": [
        "phone_number",
        "webhook_url",
        "is_set"
      ],
      "additionalProperties": false,
      "description": ""
    }
  },
  {
    "number": 31,
    "method": "GET",
    "path": "/v1/integrations/webhook2/number/:phoneNumber",
    "query": "",
    "schema": {
      "type": "object",
      "properties": {
        "phone_number": {
          "type": "string",
          "description": "Owned phone number."
        },
        "webhook_url_2": {
          "type": [
            "string",
            "null"
          ],
          "description": "Saved URL or null. Treat destination URLs as private."
        },
        "is_set": {
          "type": "boolean",
          "description": "A URL is saved at this exact level; does not resolve inheritance."
        }
      },
      "required": [
        "phone_number",
        "webhook_url_2",
        "is_set"
      ],
      "additionalProperties": false,
      "description": ""
    }
  },
  {
    "number": 37,
    "method": "GET",
    "path": "/v1/integrations/web-calls/number/:phoneNumber",
    "query": "",
    "schema": {
      "type": "object",
      "properties": {
        "phone_number": {
          "type": "string",
          "description": "Owned phone number."
        },
        "web_calls_enabled": {
          "type": "boolean",
          "description": "Saved number switch."
        }
      },
      "required": [
        "phone_number",
        "web_calls_enabled"
      ],
      "additionalProperties": false,
      "description": ""
    }
  },
  {
    "number": 41,
    "method": "GET",
    "path": "/v1/integrations/precall/number/:phoneNumber",
    "query": "",
    "schema": {
      "type": "object",
      "properties": {
        "phone_number": {
          "type": "string",
          "description": "Owned phone number."
        },
        "precall_webhook_url": {
          "type": [
            "string",
            "null"
          ],
          "description": "Saved URL or null. Treat destination URLs as private."
        },
        "is_set": {
          "type": "boolean",
          "description": "A URL is saved at this exact level; does not resolve inheritance."
        }
      },
      "required": [
        "phone_number",
        "precall_webhook_url",
        "is_set"
      ],
      "additionalProperties": false,
      "description": ""
    }
  },
  {
    "number": 44,
    "method": "GET",
    "path": "/v1/integrations/precall/agent/:agentId",
    "query": "",
    "schema": {
      "type": "object",
      "properties": {
        "agent_id": {
          "type": "string",
          "description": "Owned agent identifier."
        },
        "precall_webhook_url": {
          "type": [
            "string",
            "null"
          ],
          "description": "Saved URL or null. Treat destination URLs as private."
        },
        "is_set": {
          "type": "boolean",
          "description": "A URL is saved at this exact level; does not resolve inheritance."
        }
      },
      "required": [
        "agent_id",
        "precall_webhook_url",
        "is_set"
      ],
      "additionalProperties": false,
      "description": ""
    }
  },
  {
    "number": 47,
    "method": "GET",
    "path": "/v1/integrations/custom-functions/number/:phoneNumber",
    "query": "",
    "schema": {
      "type": "object",
      "properties": {
        "phone_number": {
          "type": "string",
          "description": "Owned phone number."
        },
        "functions": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "id": {
                "type": "string",
                "description": "Function identifier."
              },
              "name": {
                "type": "string",
                "description": "Saved name."
              },
              "description": {
                "type": "string",
                "description": "Saved description."
              },
              "method": {
                "type": "string",
                "description": "Saved HTTP method."
              },
              "url": {
                "type": "string",
                "description": "Saved destination; keep it private."
              },
              "parameters": {
                "type": "object",
                "additionalProperties": true,
                "description": "JSON object; nested properties are supplied by your integration."
              },
              "speak_during": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Saved phrase."
              },
              "timeout_ms": {
                "type": "integer",
                "description": "Saved timeout in milliseconds."
              },
              "is_active": {
                "type": "boolean",
                "description": "Saved enabled flag."
              },
              "has_headers": {
                "type": "boolean",
                "description": "Private headers exist; header values are never returned."
              }
            },
            "required": [
              "id",
              "name",
              "description",
              "method",
              "url",
              "parameters",
              "speak_during",
              "timeout_ms",
              "is_active",
              "has_headers"
            ],
            "additionalProperties": false,
            "description": ""
          },
          "description": "At most 15 functions; no cursor.",
          "maxItems": 15
        }
      },
      "required": [
        "phone_number",
        "functions"
      ],
      "additionalProperties": false,
      "description": ""
    }
  },
  {
    "number": 51,
    "method": "GET",
    "path": "/v1/account/retention",
    "query": "",
    "schema": {
      "type": "object",
      "properties": {
        "call_retention_days": {
          "type": "integer",
          "description": "Saved account default: 90, 30, 7, 1 or 0 days. Zero means delete eligible content after each call.",
          "enum": [
            90,
            30,
            7,
            1,
            0
          ]
        },
        "applies_to": {
          "type": "string",
          "description": "Only new agents inherit this default.",
          "const": "new_agents"
        },
        "processing_enabled": {
          "type": "boolean",
          "description": "Whether the retention processing feature is enabled. This does not prove that a particular record has been erased."
        }
      },
      "required": [
        "call_retention_days",
        "applies_to",
        "processing_enabled"
      ],
      "description": "",
      "additionalProperties": false
    }
  },
  {
    "number": 52,
    "method": "GET",
    "path": "/v1/agent-inbox/:channel/:number",
    "query": "?limit=2&period=all",
    "schema": {
      "type": "object",
      "properties": {
        "conversations": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "thread_key": {
                "type": "string",
                "description": "Opaque thread key."
              },
              "last_at": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Saved timestamp, or null.",
                "format": "date-time"
              },
              "msg_count": {
                "type": "integer",
                "description": "Conversation message count."
              },
              "unread_count": {
                "type": "integer",
                "description": "Unread incoming message count."
              },
              "archived": {
                "type": "boolean",
                "description": "Archived state."
              },
              "visits": {
                "type": "integer",
                "description": "Distinct visits, minimum one."
              },
              "visitor_name": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Latest visitor name when present."
              },
              "visitor_phone": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Latest visitor phone when present."
              },
              "matched": {
                "type": "boolean",
                "description": "Whether this conversation matches the search."
              },
              "last_message": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Latest message content."
              }
            },
            "required": [
              "thread_key",
              "last_at",
              "msg_count",
              "unread_count",
              "archived",
              "visits",
              "visitor_name",
              "visitor_phone",
              "matched",
              "last_message"
            ],
            "description": "",
            "additionalProperties": false
          },
          "description": ""
        },
        "total": {
          "type": "integer",
          "description": "Filtered conversations across all pages."
        },
        "archived_new": {
          "type": "integer",
          "description": "Archived conversations with unread messages, regardless of the current filters."
        },
        "unread_total": {
          "type": "integer",
          "description": "Unarchived conversations with unread messages, regardless of current filters."
        }
      },
      "required": [
        "conversations",
        "total",
        "archived_new",
        "unread_total"
      ],
      "description": "",
      "additionalProperties": false
    }
  },
  {
    "number": 53,
    "method": "GET",
    "path": "/v1/agent-inbox/:channel/:number/thread/:thread",
    "query": "?limit=2",
    "schema": {
      "type": "object",
      "properties": {
        "messages": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "id": {
                "type": "string",
                "description": "Message ID; use verbatim in the before_id cursor."
              },
              "thread_key": {
                "type": "string",
                "description": "Conversation key."
              },
              "content": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Retained message content."
              },
              "created_at": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Saved timestamp, or null.",
                "format": "date-time"
              },
              "incoming": {
                "type": "boolean",
                "description": "Incoming visitor or customer message."
              },
              "inbox_version": {
                "type": [
                  "integer",
                  "null"
                ],
                "description": "Per-message sequence when tracked; use the string read_version for acknowledgements."
              },
              "visit_id": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Web visit ID; null for SMS."
              },
              "visitor_name": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Visitor label when present."
              },
              "visitor_phone": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Visitor phone when present."
              },
              "visitor_fields": {
                "type": [
                  "array",
                  "null"
                ],
                "items": {
                  "type": "object",
                  "properties": {},
                  "description": "Saved web contact field evidence.",
                  "additionalProperties": true
                },
                "description": "Web messages only; up to nine saved fields.",
                "maxItems": 9
              },
              "knowledge_given": {
                "description": "Optional saved outgoing knowledge evidence when available. This additive data does not change thread pagination.",
                "type": [
                  "object",
                  "array",
                  "null"
                ],
                "additionalProperties": true
              }
            },
            "required": [
              "id",
              "thread_key",
              "content",
              "created_at",
              "incoming",
              "inbox_version",
              "visit_id",
              "visitor_name",
              "visitor_phone"
            ],
            "description": "",
            "additionalProperties": false
          },
          "description": ""
        },
        "read_version": {
          "type": "string",
          "description": "Maximum tracked version across the whole thread, including messages outside this page. Opaque decimal string; default 0."
        },
        "has_more": {
          "type": "boolean",
          "description": "More older messages remain before this page boundary."
        }
      },
      "required": [
        "messages",
        "read_version",
        "has_more"
      ],
      "description": "",
      "additionalProperties": false
    }
  },
  {
    "number": 55,
    "method": "GET",
    "path": "/v1/agent-inbox/features",
    "query": "",
    "schema": {
      "type": "object",
      "properties": {
        "enabled": {
          "type": "boolean",
          "description": "Current inbox feature flag."
        }
      },
      "required": [
        "enabled"
      ],
      "description": "",
      "additionalProperties": false
    }
  },
  {
    "number": 56,
    "method": "GET",
    "path": "/v1/agent-inbox/numbers",
    "query": "?offset=0",
    "schema": {
      "type": "object",
      "properties": {
        "numbers": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "phone_number": {
                "type": "string",
                "description": "International number with + and digits; no spaces.",
                "pattern": "^\\+[1-9][0-9]{6,14}$"
              },
              "agent_id": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Assigned agent ID."
              },
              "source": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Saved source."
              },
              "sms_prompt": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "SMS instructions."
              },
              "web_prompt": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Website instructions."
              },
              "sms_reply_enabled": {
                "type": [
                  "boolean",
                  "null"
                ],
                "description": "SMS reply setting."
              },
              "web_agent_enabled": {
                "type": [
                  "boolean",
                  "null"
                ],
                "description": "Web chat setting."
              },
              "web_calls_enabled": {
                "type": [
                  "boolean",
                  "null"
                ],
                "description": "Website voice setting."
              }
            },
            "required": [
              "phone_number",
              "agent_id",
              "source",
              "sms_prompt",
              "web_prompt",
              "sms_reply_enabled",
              "web_agent_enabled",
              "web_calls_enabled"
            ],
            "description": "",
            "additionalProperties": false
          },
          "description": ""
        },
        "agents": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "agent_id": {
                "type": "string",
                "description": "Active agent ID."
              },
              "name": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Agent label."
              }
            },
            "required": [
              "agent_id",
              "name"
            ],
            "description": "",
            "additionalProperties": false
          },
          "description": "At most 1,000 active agents, ordered by agent_id."
        },
        "has_more": {
          "type": "boolean",
          "description": "True when the number page contains exactly 100 rows; another page may be empty."
        }
      },
      "required": [
        "numbers",
        "agents",
        "has_more"
      ],
      "description": "",
      "additionalProperties": false
    }
  },
  {
    "number": 57,
    "method": "GET",
    "path": "/v1/agent-inbox/retention",
    "query": "?number=%2B12025550123",
    "schema": {
      "type": "object",
      "properties": {
        "call_retention_days": {
          "type": "integer",
          "description": "Account retention default, 90 when unset."
        },
        "web_days": {
          "type": [
            "integer",
            "null"
          ],
          "description": "Effective agent or account web days when number is supplied; null without number."
        },
        "web_expiry_confirmed": {
          "type": "boolean",
          "description": "Web cleanup database prerequisites are confirmed."
        },
        "applies_to": {
          "type": "string",
          "description": "Policy scope.",
          "const": "new_messages_agent_policy"
        },
        "legacy_web_policy": {
          "type": "string",
          "description": "Legacy-message fallback.",
          "const": "account_policy_at_creation_or_90_days"
        },
        "zero_days_means": {
          "type": "string",
          "description": "Zero-day cleanup timing.",
          "const": "next_cleanup_after_reply"
        },
        "archive_changes_retention": {
          "type": "boolean",
          "description": "Archiving does not change retention.",
          "const": false
        },
        "sms_days": {
          "type": "integer",
          "description": "SMS retention days.",
          "const": 90
        },
        "sms_processing_enabled": {
          "type": "boolean",
          "description": "SMS cleanup processing is enabled."
        },
        "web_processing_enabled": {
          "type": "boolean",
          "description": "Cleanup enabled and web prerequisites confirmed."
        }
      },
      "required": [
        "call_retention_days",
        "web_days",
        "web_expiry_confirmed",
        "applies_to",
        "legacy_web_policy",
        "zero_days_means",
        "archive_changes_retention",
        "sms_days",
        "sms_processing_enabled",
        "web_processing_enabled"
      ],
      "description": "",
      "additionalProperties": false
    }
  },
  {
    "number": 58,
    "method": "GET",
    "path": "/v1/agent-web/:number",
    "query": "",
    "schema": {
      "type": "object",
      "properties": {
        "phone_number": {
          "type": "string",
          "description": "International number with + and digits; no spaces.",
          "pattern": "^\\+[1-9][0-9]{6,14}$"
        },
        "agent_id": {
          "type": [
            "string",
            "null"
          ],
          "description": "Assigned agent."
        },
        "web_prompt": {
          "type": [
            "string",
            "null"
          ],
          "description": "Saved website instructions."
        },
        "web_appearance": {
          "type": [
            "object",
            "null"
          ],
          "properties": {
            "version": {
              "type": "integer",
              "description": "Appearance schema version.",
              "const": 1
            },
            "launcher": {
              "type": "string",
              "description": "Launcher identifier.",
              "pattern": "^[a-z][a-z0-9-]{0,31}$"
            },
            "window": {
              "type": "string",
              "description": "Window layout.",
              "enum": [
                "compact",
                "side",
                "centre",
                "full"
              ]
            },
            "visit": {
              "type": "string",
              "description": "Initial visit action.",
              "enum": [
                "nothing",
                "greeting",
                "open"
              ]
            },
            "theme": {
              "type": "string",
              "description": "Colour theme.",
              "enum": [
                "dark",
                "light"
              ]
            },
            "colourMode": {
              "type": "string",
              "description": "Colour mode.",
              "enum": [
                "solid",
                "gradient"
              ]
            },
            "colour": {
              "type": "string",
              "description": "Primary RGB hex colour.",
              "pattern": "^#[0-9a-fA-F]{6}$"
            },
            "colour2": {
              "type": "string",
              "description": "Secondary RGB hex colour.",
              "pattern": "^#[0-9a-fA-F]{6}$"
            },
            "text": {
              "type": "object",
              "properties": {
                "greeting": {
                  "type": "string",
                  "description": "Optional greeting wording.",
                  "maxLength": 500
                },
                "button": {
                  "type": "string",
                  "description": "Optional button wording.",
                  "maxLength": 500
                },
                "title": {
                  "type": "string",
                  "description": "Optional title wording.",
                  "maxLength": 500
                },
                "subtitle": {
                  "type": "string",
                  "description": "Optional subtitle wording.",
                  "maxLength": 500
                },
                "call": {
                  "type": "string",
                  "description": "Optional call wording.",
                  "maxLength": 500
                },
                "chat": {
                  "type": "string",
                  "description": "Optional chat wording.",
                  "maxLength": 500
                },
                "welcome": {
                  "type": "string",
                  "description": "Optional welcome wording.",
                  "maxLength": 500
                },
                "placeholder": {
                  "type": "string",
                  "description": "Optional placeholder wording.",
                  "maxLength": 500
                },
                "status": {
                  "type": "string",
                  "description": "Optional status wording.",
                  "maxLength": 500
                },
                "send": {
                  "type": "string",
                  "description": "Optional send wording.",
                  "maxLength": 500
                },
                "close": {
                  "type": "string",
                  "description": "Optional close wording.",
                  "maxLength": 500
                },
                "footer": {
                  "type": "string",
                  "description": "Always normalised to Powered by Nixflex on write and read.",
                  "maxLength": 500
                },
                "typing": {
                  "type": "string",
                  "description": "Optional typing wording.",
                  "maxLength": 500
                },
                "error": {
                  "type": "string",
                  "description": "Optional error wording.",
                  "maxLength": 500
                },
                "contact": {
                  "type": "string",
                  "description": "Optional contact wording.",
                  "maxLength": 500
                },
                "contactNote": {
                  "type": "string",
                  "description": "Optional contactNote wording.",
                  "maxLength": 500
                },
                "contactName": {
                  "type": "string",
                  "description": "Optional contactName wording.",
                  "maxLength": 500
                },
                "contactPhone": {
                  "type": "string",
                  "description": "Optional contactPhone wording.",
                  "maxLength": 500
                },
                "avatar": {
                  "type": "string",
                  "description": "Optional avatar wording.",
                  "maxLength": 500
                },
                "voiceConnecting": {
                  "type": "string",
                  "description": "Optional voiceConnecting wording.",
                  "maxLength": 500
                },
                "voicePrivacy": {
                  "type": "string",
                  "description": "Optional voicePrivacy wording.",
                  "maxLength": 500
                },
                "voiceMute": {
                  "type": "string",
                  "description": "Optional voiceMute wording.",
                  "maxLength": 500
                },
                "voiceUnmute": {
                  "type": "string",
                  "description": "Optional voiceUnmute wording.",
                  "maxLength": 500
                },
                "voiceEnd": {
                  "type": "string",
                  "description": "Optional voiceEnd wording.",
                  "maxLength": 500
                },
                "voiceAllow": {
                  "type": "string",
                  "description": "Optional voiceAllow wording.",
                  "maxLength": 500
                },
                "voiceCancel": {
                  "type": "string",
                  "description": "Optional voiceCancel wording.",
                  "maxLength": 500
                },
                "voiceEnded": {
                  "type": "string",
                  "description": "Optional voiceEnded wording.",
                  "maxLength": 500
                },
                "voiceYouEnded": {
                  "type": "string",
                  "description": "Optional voiceYouEnded wording.",
                  "maxLength": 500
                },
                "voiceUnavailable": {
                  "type": "string",
                  "description": "Optional voiceUnavailable wording.",
                  "maxLength": 500
                },
                "voiceUnavailableNote": {
                  "type": "string",
                  "description": "Optional voiceUnavailableNote wording.",
                  "maxLength": 500
                },
                "voiceDisabled": {
                  "type": "string",
                  "description": "Optional voiceDisabled wording.",
                  "maxLength": 500
                },
                "voiceInsecure": {
                  "type": "string",
                  "description": "Optional voiceInsecure wording.",
                  "maxLength": 500
                },
                "voiceInsecureNote": {
                  "type": "string",
                  "description": "Optional voiceInsecureNote wording.",
                  "maxLength": 500
                },
                "voicePermission": {
                  "type": "string",
                  "description": "Optional voicePermission wording.",
                  "maxLength": 500
                },
                "voicePermissionNote": {
                  "type": "string",
                  "description": "Optional voicePermissionNote wording.",
                  "maxLength": 500
                },
                "voiceChecking": {
                  "type": "string",
                  "description": "Optional voiceChecking wording.",
                  "maxLength": 500
                },
                "voiceNeeded": {
                  "type": "string",
                  "description": "Optional voiceNeeded wording.",
                  "maxLength": 500
                },
                "voiceBlocked": {
                  "type": "string",
                  "description": "Optional voiceBlocked wording.",
                  "maxLength": 500
                },
                "voiceMissing": {
                  "type": "string",
                  "description": "Optional voiceMissing wording.",
                  "maxLength": 500
                },
                "voiceInUse": {
                  "type": "string",
                  "description": "Optional voiceInUse wording.",
                  "maxLength": 500
                },
                "voiceMicError": {
                  "type": "string",
                  "description": "Optional voiceMicError wording.",
                  "maxLength": 500
                },
                "voiceBusy": {
                  "type": "string",
                  "description": "Optional voiceBusy wording.",
                  "maxLength": 500
                },
                "voiceBusyNote": {
                  "type": "string",
                  "description": "Optional voiceBusyNote wording.",
                  "maxLength": 500
                },
                "voiceRinging": {
                  "type": "string",
                  "description": "Optional voiceRinging wording.",
                  "maxLength": 500
                },
                "voiceLive": {
                  "type": "string",
                  "description": "Optional voiceLive wording.",
                  "maxLength": 500
                },
                "voiceError": {
                  "type": "string",
                  "description": "Optional voiceError wording.",
                  "maxLength": 500
                },
                "contactSave": {
                  "type": "string",
                  "description": "Optional contactSave wording.",
                  "maxLength": 500
                },
                "contactSavedEdit": {
                  "type": "string",
                  "description": "Optional contactSavedEdit wording.",
                  "maxLength": 500
                },
                "contactRequired": {
                  "type": "string",
                  "description": "Optional contactRequired wording.",
                  "maxLength": 500
                },
                "beforeCallStart": {
                  "type": "string",
                  "description": "Optional beforeCallStart wording.",
                  "maxLength": 500
                },
                "beforeCallCancel": {
                  "type": "string",
                  "description": "Optional beforeCallCancel wording.",
                  "maxLength": 500
                }
              },
              "description": "Allowed wording keys; omitted keys are not automatically preserved when replacing appearance.",
              "additionalProperties": false
            },
            "contactFields": {
              "type": "array",
              "items": {
                "type": "object",
                "properties": {
                  "id": {
                    "type": "string",
                    "description": "Built-in field or one of five custom fields.",
                    "pattern": "^(name|phone|email|order|custom_[1-5])$"
                  },
                  "label": {
                    "type": "string",
                    "description": "Nonblank label, no control characters; trimmed and raw length at most 60.",
                    "minLength": 1,
                    "maxLength": 60
                  },
                  "enabled": {
                    "type": "boolean",
                    "description": "Field enabled."
                  },
                  "required": {
                    "type": "boolean",
                    "description": "Field required."
                  },
                  "askInChat": {
                    "type": "boolean",
                    "description": "Optional request-in-chat flag. If absent, a disabled field cannot be required."
                  }
                },
                "required": [
                  "id",
                  "label",
                  "enabled",
                  "required"
                ],
                "description": "",
                "additionalProperties": false
              },
              "description": "Up to nine fields; IDs must be unique.",
              "maxItems": 9
            },
            "beforeCall": {
              "type": "object",
              "properties": {
                "enabled": {
                  "type": "boolean",
                  "description": "Use a contact form before a web call."
                },
                "message": {
                  "type": "string",
                  "description": "Before-call message.",
                  "maxLength": 500
                },
                "fields": {
                  "type": "array",
                  "items": {
                    "type": "object",
                    "properties": {
                      "id": {
                        "type": "string",
                        "description": "Built-in field or one of five custom fields.",
                        "pattern": "^(name|phone|email|order|custom_[1-5])$"
                      },
                      "required": {
                        "type": "boolean",
                        "description": "Required before starting."
                      }
                    },
                    "required": [
                      "id",
                      "required"
                    ],
                    "description": "",
                    "additionalProperties": false
                  },
                  "description": "Up to nine unique IDs. Each custom ID must exist in contactFields.",
                  "maxItems": 9
                }
              },
              "required": [
                "enabled",
                "message",
                "fields"
              ],
              "description": "",
              "additionalProperties": false
            }
          },
          "required": [
            "version",
            "launcher",
            "window",
            "visit",
            "theme",
            "colourMode",
            "colour",
            "colour2",
            "text"
          ],
          "description": "Complete appearance value, not a nested merge. Database JSON representation must be at most 32,000 bytes.",
          "additionalProperties": false
        },
        "appearance_version": {
          "type": "integer",
          "description": "Current appearance schema version.",
          "const": 1
        },
        "web_design": {
          "type": "integer",
          "description": "Saved design, displayed as 1 when unset."
        },
        "web_color": {
          "type": "string",
          "description": "Saved colour, displayed as #25D366 when unset."
        },
        "web_name": {
          "type": "string",
          "description": "Saved name, displayed as empty when unset."
        },
        "web_chips": {
          "type": "string",
          "description": "Saved comma-separated questions, empty when unset."
        },
        "web_calls_enabled": {
          "type": "boolean",
          "description": "Saved voice setting, false when unset."
        },
        "web_agent_enabled": {
          "type": [
            "boolean",
            "null"
          ],
          "description": "Current chat enabled setting; read-only here."
        },
        "revision": {
          "type": "string",
          "description": "Opaque decimal settings revision. Send current value in PATCH; 0 before an installation exists."
        },
        "install_id": {
          "type": [
            "string",
            "null"
          ],
          "description": "Public widget installation ID, not an API credential."
        },
        "first_seen_at": {
          "type": [
            "string",
            "null"
          ],
          "description": "Saved timestamp, or null.",
          "format": "date-time"
        },
        "last_seen_at": {
          "type": [
            "string",
            "null"
          ],
          "description": "Saved timestamp, or null.",
          "format": "date-time"
        }
      },
      "required": [
        "phone_number",
        "agent_id",
        "web_prompt",
        "web_appearance",
        "appearance_version",
        "web_design",
        "web_color",
        "web_name",
        "web_chips",
        "web_calls_enabled",
        "web_agent_enabled",
        "revision",
        "install_id",
        "first_seen_at",
        "last_seen_at"
      ],
      "description": "",
      "additionalProperties": false
    }
  },
  {
    "number": 60,
    "method": "GET",
    "path": "/v1/agents",
    "query": "?limit=1",
    "schema": {
      "type": "array",
      "items": {
        "type": "object",
        "description": "One safe projection for create, update, get and list. No secrets or automatic future-column exposure.",
        "properties": {
          "is_active": {
            "type": "boolean"
          },
          "ai_speaks_first": {
            "type": "boolean"
          },
          "dynamic_greeting": {
            "type": "boolean"
          },
          "func_end_call": {
            "type": "boolean"
          },
          "func_cold_transfer": {
            "type": "boolean"
          },
          "func_send_sms": {
            "type": "boolean"
          },
          "record_call": {
            "type": "boolean"
          },
          "post_call_sms_enabled": {
            "type": "boolean"
          },
          "incall_sms_enabled": {
            "type": "boolean"
          },
          "amd_enabled": {
            "type": "boolean"
          },
          "greet_by_name": {
            "type": "boolean"
          },
          "remember_callers": {
            "type": "boolean"
          },
          "require_booking_confirmation": {
            "type": "boolean"
          },
          "voicemail_leave_enabled": {
            "type": "boolean"
          },
          "name": {
            "type": "string"
          },
          "system_prompt": {
            "type": "string"
          },
          "welcome_message": {
            "type": "string"
          },
          "voice_id": {
            "type": [
              "string",
              "null"
            ]
          },
          "voice_key": {
            "type": [
              "string",
              "null"
            ]
          },
          "language": {
            "type": "string"
          },
          "webhook_url": {
            "type": [
              "string",
              "null"
            ]
          },
          "phone_number": {
            "type": [
              "string",
              "null"
            ]
          },
          "llm_model": {
            "type": "string"
          },
          "fallback_message": {
            "type": "string"
          },
          "post_call_sms_template": {
            "type": "string"
          },
          "transfer_number": {
            "type": [
              "string",
              "null"
            ]
          },
          "transfer_whisper": {
            "type": [
              "string",
              "null"
            ]
          },
          "timezone": {
            "type": "string"
          },
          "boosted_keywords": {
            "type": [
              "string",
              "null"
            ]
          },
          "voicemail_message": {
            "type": [
              "string",
              "null"
            ]
          },
          "temperature": {
            "type": "number"
          },
          "response_eagerness": {
            "type": "integer"
          },
          "stt_confidence": {
            "type": "number"
          },
          "stt_max_silence_ms": {
            "type": "integer"
          },
          "interruption_sensitivity": {
            "type": "integer"
          },
          "max_call_duration_seconds": {
            "type": [
              "integer",
              "null"
            ]
          },
          "silence_hangup_seconds": {
            "type": [
              "integer",
              "null"
            ]
          },
          "wait_tag_seconds": {
            "type": [
              "integer",
              "null"
            ]
          },
          "ivr_timeout_seconds": {
            "type": "integer"
          },
          "voice_speed": {
            "type": "number"
          },
          "dtmf_enabled": {
            "type": [
              "boolean",
              "null"
            ]
          },
          "response_length": {
            "type": "string",
            "enum": [
              "short",
              "medium",
              "long"
            ]
          },
          "transfer_type": {
            "type": "string",
            "enum": [
              "cold",
              "warm"
            ]
          },
          "recording_source": {
            "type": [
              "string",
              "null"
            ],
            "enum": [
              "provider",
              "nixflex",
              null
            ]
          },
          "data_extraction_fields": {
            "type": "array",
            "items": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "name",
                "type"
              ],
              "properties": {
                "name": {
                  "type": "string",
                  "pattern": "^[A-Za-z_][A-Za-z0-9_]{0,63}$",
                  "description": "Unique; __proto__, constructor and prototype forbidden."
                },
                "type": {
                  "type": "string",
                  "enum": [
                    "text",
                    "selector",
                    "boolean",
                    "number"
                  ]
                },
                "description": {
                  "type": "string",
                  "maxLength": 2000
                },
                "optional": {
                  "type": "boolean"
                },
                "format_example": {
                  "type": "string",
                  "maxLength": 2000
                },
                "choices": {
                  "type": "array",
                  "maxItems": 100,
                  "uniqueItems": true,
                  "items": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 200
                  },
                  "description": "Required non-empty for selector; whitespace-only choices rejected."
                }
              }
            }
          },
          "pickup_delay": {
            "type": [
              "integer",
              "null"
            ]
          },
          "speaking_rate": {
            "type": [
              "number",
              "null"
            ]
          },
          "id": {
            "type": "string",
            "readOnly": true
          },
          "agent_id": {
            "type": "string",
            "readOnly": true
          },
          "api_key_id": {
            "type": "string",
            "readOnly": true
          },
          "created_at": {
            "type": "string",
            "readOnly": true
          },
          "updated_at": {
            "type": "string",
            "readOnly": true
          },
          "greeting_language": {
            "type": [
              "string",
              "null"
            ],
            "readOnly": true
          },
          "precall_webhook_url": {
            "type": [
              "string",
              "null"
            ],
            "readOnly": true
          },
          "tester_scenarios": {
            "type": "array",
            "items": {},
            "readOnly": true
          },
          "outbound_transfer_numbers": {
            "type": "array",
            "items": {},
            "readOnly": true
          },
          "outbound_warm_transfer_numbers": {
            "type": "array",
            "items": {},
            "readOnly": true
          },
          "outbound_post_call_sms_templates": {
            "type": "array",
            "items": {},
            "readOnly": true
          },
          "outbound_max_duration_seconds": {
            "type": [
              "integer",
              "null"
            ],
            "readOnly": true
          },
          "outbound_silence_hangup_seconds": {
            "type": [
              "integer",
              "null"
            ],
            "readOnly": true
          },
          "call_retention_days": {
            "type": "integer",
            "enum": [
              90,
              30,
              7,
              1,
              0
            ]
          },
          "warnings": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "code": {
                  "type": "string",
                  "enum": [
                    "unknown_fields"
                  ]
                },
                "fields": {
                  "type": "array",
                  "items": {
                    "type": "string"
                  }
                },
                "message": {
                  "type": "string"
                }
              }
            }
          }
        },
        "additionalProperties": false
      }
    }
  },
  {
    "number": 63,
    "method": "GET",
    "path": "/v1/agents/:id",
    "query": "",
    "schema": {
      "type": "object",
      "description": "One safe projection for create, update, get and list. No secrets or automatic future-column exposure.",
      "properties": {
        "is_active": {
          "type": "boolean"
        },
        "ai_speaks_first": {
          "type": "boolean"
        },
        "dynamic_greeting": {
          "type": "boolean"
        },
        "func_end_call": {
          "type": "boolean"
        },
        "func_cold_transfer": {
          "type": "boolean"
        },
        "func_send_sms": {
          "type": "boolean"
        },
        "record_call": {
          "type": "boolean"
        },
        "post_call_sms_enabled": {
          "type": "boolean"
        },
        "incall_sms_enabled": {
          "type": "boolean"
        },
        "amd_enabled": {
          "type": "boolean"
        },
        "greet_by_name": {
          "type": "boolean"
        },
        "remember_callers": {
          "type": "boolean"
        },
        "require_booking_confirmation": {
          "type": "boolean"
        },
        "voicemail_leave_enabled": {
          "type": "boolean"
        },
        "name": {
          "type": "string"
        },
        "system_prompt": {
          "type": "string"
        },
        "welcome_message": {
          "type": "string"
        },
        "voice_id": {
          "type": [
            "string",
            "null"
          ]
        },
        "voice_key": {
          "type": [
            "string",
            "null"
          ]
        },
        "language": {
          "type": "string"
        },
        "webhook_url": {
          "type": [
            "string",
            "null"
          ]
        },
        "phone_number": {
          "type": [
            "string",
            "null"
          ]
        },
        "llm_model": {
          "type": "string"
        },
        "fallback_message": {
          "type": "string"
        },
        "post_call_sms_template": {
          "type": "string"
        },
        "transfer_number": {
          "type": [
            "string",
            "null"
          ]
        },
        "transfer_whisper": {
          "type": [
            "string",
            "null"
          ]
        },
        "timezone": {
          "type": "string"
        },
        "boosted_keywords": {
          "type": [
            "string",
            "null"
          ]
        },
        "voicemail_message": {
          "type": [
            "string",
            "null"
          ]
        },
        "temperature": {
          "type": "number"
        },
        "response_eagerness": {
          "type": "integer"
        },
        "stt_confidence": {
          "type": "number"
        },
        "stt_max_silence_ms": {
          "type": "integer"
        },
        "interruption_sensitivity": {
          "type": "integer"
        },
        "max_call_duration_seconds": {
          "type": [
            "integer",
            "null"
          ]
        },
        "silence_hangup_seconds": {
          "type": [
            "integer",
            "null"
          ]
        },
        "wait_tag_seconds": {
          "type": [
            "integer",
            "null"
          ]
        },
        "ivr_timeout_seconds": {
          "type": "integer"
        },
        "voice_speed": {
          "type": "number"
        },
        "dtmf_enabled": {
          "type": [
            "boolean",
            "null"
          ]
        },
        "response_length": {
          "type": "string",
          "enum": [
            "short",
            "medium",
            "long"
          ]
        },
        "transfer_type": {
          "type": "string",
          "enum": [
            "cold",
            "warm"
          ]
        },
        "recording_source": {
          "type": [
            "string",
            "null"
          ],
          "enum": [
            "provider",
            "nixflex",
            null
          ]
        },
        "data_extraction_fields": {
          "type": "array",
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "name",
              "type"
            ],
            "properties": {
              "name": {
                "type": "string",
                "pattern": "^[A-Za-z_][A-Za-z0-9_]{0,63}$",
                "description": "Unique; __proto__, constructor and prototype forbidden."
              },
              "type": {
                "type": "string",
                "enum": [
                  "text",
                  "selector",
                  "boolean",
                  "number"
                ]
              },
              "description": {
                "type": "string",
                "maxLength": 2000
              },
              "optional": {
                "type": "boolean"
              },
              "format_example": {
                "type": "string",
                "maxLength": 2000
              },
              "choices": {
                "type": "array",
                "maxItems": 100,
                "uniqueItems": true,
                "items": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 200
                },
                "description": "Required non-empty for selector; whitespace-only choices rejected."
              }
            }
          }
        },
        "pickup_delay": {
          "type": [
            "integer",
            "null"
          ]
        },
        "speaking_rate": {
          "type": [
            "number",
            "null"
          ]
        },
        "id": {
          "type": "string",
          "readOnly": true
        },
        "agent_id": {
          "type": "string",
          "readOnly": true
        },
        "api_key_id": {
          "type": "string",
          "readOnly": true
        },
        "created_at": {
          "type": "string",
          "readOnly": true
        },
        "updated_at": {
          "type": "string",
          "readOnly": true
        },
        "greeting_language": {
          "type": [
            "string",
            "null"
          ],
          "readOnly": true
        },
        "precall_webhook_url": {
          "type": [
            "string",
            "null"
          ],
          "readOnly": true
        },
        "tester_scenarios": {
          "type": "array",
          "items": {},
          "readOnly": true
        },
        "outbound_transfer_numbers": {
          "type": "array",
          "items": {},
          "readOnly": true
        },
        "outbound_warm_transfer_numbers": {
          "type": "array",
          "items": {},
          "readOnly": true
        },
        "outbound_post_call_sms_templates": {
          "type": "array",
          "items": {},
          "readOnly": true
        },
        "outbound_max_duration_seconds": {
          "type": [
            "integer",
            "null"
          ],
          "readOnly": true
        },
        "outbound_silence_hangup_seconds": {
          "type": [
            "integer",
            "null"
          ],
          "readOnly": true
        },
        "call_retention_days": {
          "type": "integer",
          "enum": [
            90,
            30,
            7,
            1,
            0
          ]
        },
        "warnings": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "code": {
                "type": "string",
                "enum": [
                  "unknown_fields"
                ]
              },
              "fields": {
                "type": "array",
                "items": {
                  "type": "string"
                }
              },
              "message": {
                "type": "string"
              }
            }
          }
        },
        "knowledge_keyterms": {
          "type": "array",
          "items": {
            "type": "string"
          },
          "maxItems": 100,
          "description": "Optional when knowledge is enabled. Ranked live automatic terms, filtered against saved customer terms; default cap 80, platform-configurable. Read-only."
        }
      },
      "additionalProperties": false
    }
  },
  {
    "number": 66,
    "method": "GET",
    "path": "/v1/agents/:target/knowledge-base",
    "query": "",
    "schema": {
      "type": "object",
      "properties": {
        "mode": {
          "type": "string",
          "description": "",
          "const": "own"
        },
        "own": {
          "type": [
            "object",
            "null"
          ],
          "properties": {
            "id": {
              "type": "string",
              "description": "Opaque identifier. Keep it as a string.",
              "format": "uuid"
            },
            "owner": {
              "type": "string",
              "description": "Owning account identifier; it never grants access when sent by a caller."
            },
            "kind": {
              "type": "string",
              "description": "Knowledge belongs to an agent.",
              "const": "agent"
            },
            "target": {
              "type": "string",
              "description": "Owning agent ID."
            },
            "rev": {
              "type": "integer",
              "description": "Latest integer revision read from this resource; it must still match when the request runs.",
              "minimum": 1
            },
            "active": {
              "type": [
                "string",
                "null"
              ],
              "description": "Active published index revision, or null before publication.",
              "format": "uuid"
            },
            "state": {
              "type": "string",
              "description": "Lifecycle state.",
              "enum": [
                "ready",
                "deleting",
                "deleted"
              ]
            },
            "settings": {
              "type": "object",
              "properties": {
                "channels": {
                  "type": "array",
                  "items": {
                    "type": "string",
                    "description": "Channel identifier.",
                    "enum": [
                      "inbound",
                      "outbound",
                      "web_voice",
                      "web_chat",
                      "sms"
                    ]
                  },
                  "description": "Enabled knowledge channels. An empty list turns knowledge off for all channels.",
                  "uniqueItems": true,
                  "default": [
                    "inbound"
                  ]
                },
                "match": {
                  "type": "string",
                  "description": "Answer matching mode.",
                  "enum": [
                    "Strict",
                    "Normal"
                  ],
                  "default": "Strict"
                },
                "not_found": {
                  "type": "string",
                  "description": "Nonblank response when suitable knowledge is missing.",
                  "minLength": 1,
                  "maxLength": 500,
                  "default": "I don't have that information right now."
                }
              },
              "additionalProperties": false,
              "description": "Only channels, match and not_found may be supplied. Omitted settings retain the saved value on update."
            },
            "tombstones": {
              "type": "array",
              "items": {
                "type": "object",
                "properties": {
                  "id": {
                    "type": "string",
                    "description": "Opaque identifier. Keep it as a string.",
                    "format": "uuid"
                  },
                  "subject_hash": {
                    "type": "string",
                    "description": "Normalized title digest."
                  },
                  "evidence": {
                    "type": "array",
                    "items": {
                      "type": "object",
                      "properties": {
                        "source": {
                          "type": "string",
                          "description": "Opaque identifier. Keep it as a string.",
                          "format": "uuid"
                        },
                        "segment": {
                          "type": "integer",
                          "description": "Source segment index."
                        },
                        "quote": {
                          "type": "string",
                          "description": "Original evidence text."
                        },
                        "quote_hash": {
                          "type": "string",
                          "description": "Digest used by a deletion record."
                        },
                        "topic_id": {
                          "type": "string",
                          "description": "Opaque identifier. Keep it as a string.",
                          "format": "uuid"
                        },
                        "revision": {
                          "type": "string",
                          "description": "Opaque identifier. Keep it as a string.",
                          "format": "uuid"
                        },
                        "title": {
                          "type": "string",
                          "description": "Title snapshot at answer time."
                        }
                      },
                      "additionalProperties": true,
                      "description": "Evidence fields vary by source, topic or answer. IDs identify supplied context, not proof that every piece affected an answer."
                    },
                    "description": ""
                  }
                },
                "required": [
                  "id",
                  "subject_hash",
                  "evidence"
                ],
                "additionalProperties": true,
                "description": ""
              },
              "description": "Records that prevent refreshed sources restoring removed pieces."
            },
            "created_at": {
              "type": "string",
              "description": "UTC timestamp.",
              "format": "date-time"
            }
          },
          "required": [
            "id",
            "owner",
            "kind",
            "target",
            "rev",
            "active",
            "state",
            "settings",
            "tombstones",
            "created_at"
          ],
          "additionalProperties": true,
          "description": ""
        },
        "effective": {
          "type": [
            "object",
            "null"
          ],
          "properties": {
            "id": {
              "type": "string",
              "description": "Opaque identifier. Keep it as a string.",
              "format": "uuid"
            },
            "owner": {
              "type": "string",
              "description": "Owning account identifier; it never grants access when sent by a caller."
            },
            "kind": {
              "type": "string",
              "description": "Knowledge belongs to an agent.",
              "const": "agent"
            },
            "target": {
              "type": "string",
              "description": "Owning agent ID."
            },
            "rev": {
              "type": "integer",
              "description": "Latest integer revision read from this resource; it must still match when the request runs.",
              "minimum": 1
            },
            "active": {
              "type": [
                "string",
                "null"
              ],
              "description": "Active published index revision, or null before publication.",
              "format": "uuid"
            },
            "state": {
              "type": "string",
              "description": "Lifecycle state.",
              "enum": [
                "ready",
                "deleting",
                "deleted"
              ]
            },
            "settings": {
              "type": "object",
              "properties": {
                "channels": {
                  "type": "array",
                  "items": {
                    "type": "string",
                    "description": "Channel identifier.",
                    "enum": [
                      "inbound",
                      "outbound",
                      "web_voice",
                      "web_chat",
                      "sms"
                    ]
                  },
                  "description": "Enabled knowledge channels. An empty list turns knowledge off for all channels.",
                  "uniqueItems": true,
                  "default": [
                    "inbound"
                  ]
                },
                "match": {
                  "type": "string",
                  "description": "Answer matching mode.",
                  "enum": [
                    "Strict",
                    "Normal"
                  ],
                  "default": "Strict"
                },
                "not_found": {
                  "type": "string",
                  "description": "Nonblank response when suitable knowledge is missing.",
                  "minLength": 1,
                  "maxLength": 500,
                  "default": "I don't have that information right now."
                }
              },
              "additionalProperties": false,
              "description": "Only channels, match and not_found may be supplied. Omitted settings retain the saved value on update."
            },
            "tombstones": {
              "type": "array",
              "items": {
                "type": "object",
                "properties": {
                  "id": {
                    "type": "string",
                    "description": "Opaque identifier. Keep it as a string.",
                    "format": "uuid"
                  },
                  "subject_hash": {
                    "type": "string",
                    "description": "Normalized title digest."
                  },
                  "evidence": {
                    "type": "array",
                    "items": {
                      "type": "object",
                      "properties": {
                        "source": {
                          "type": "string",
                          "description": "Opaque identifier. Keep it as a string.",
                          "format": "uuid"
                        },
                        "segment": {
                          "type": "integer",
                          "description": "Source segment index."
                        },
                        "quote": {
                          "type": "string",
                          "description": "Original evidence text."
                        },
                        "quote_hash": {
                          "type": "string",
                          "description": "Digest used by a deletion record."
                        },
                        "topic_id": {
                          "type": "string",
                          "description": "Opaque identifier. Keep it as a string.",
                          "format": "uuid"
                        },
                        "revision": {
                          "type": "string",
                          "description": "Opaque identifier. Keep it as a string.",
                          "format": "uuid"
                        },
                        "title": {
                          "type": "string",
                          "description": "Title snapshot at answer time."
                        }
                      },
                      "additionalProperties": true,
                      "description": "Evidence fields vary by source, topic or answer. IDs identify supplied context, not proof that every piece affected an answer."
                    },
                    "description": ""
                  }
                },
                "required": [
                  "id",
                  "subject_hash",
                  "evidence"
                ],
                "additionalProperties": true,
                "description": ""
              },
              "description": "Records that prevent refreshed sources restoring removed pieces."
            },
            "created_at": {
              "type": "string",
              "description": "UTC timestamp.",
              "format": "date-time"
            }
          },
          "required": [
            "id",
            "owner",
            "kind",
            "target",
            "rev",
            "active",
            "state",
            "settings",
            "tombstones",
            "created_at"
          ],
          "additionalProperties": true,
          "description": ""
        },
        "policy_revision": {
          "type": "integer",
          "description": "Compatibility value; zero for agent-only knowledge.",
          "const": 0
        }
      },
      "required": [
        "mode",
        "own",
        "effective",
        "policy_revision"
      ],
      "additionalProperties": true,
      "description": ""
    }
  },
  {
    "number": 84,
    "method": "GET",
    "path": "/v1/calls",
    "query": "?limit=25&offset=0",
    "schema": {
      "anyOf": [
        {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "call_id": {
                "type": "string",
                "description": "Call identifier. Failed starts can use the failed: prefix."
              },
              "id": {
                "type": "string",
                "description": "Internal row identifier when present.",
                "format": "uuid"
              },
              "agent_id": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Agent identifier, if retained."
              },
              "from_number": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Origin number, if retained."
              },
              "to_number": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Destination number, if retained."
              },
              "call_type": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Call channel/type, such as inbound, outbound or web."
              },
              "call_direction": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Direction recorded for the call."
              },
              "call_status": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Recorded lifecycle state; unknown future states must be tolerated."
              },
              "duration_ms": {
                "type": [
                  "integer",
                  "null"
                ],
                "description": "Connected duration in milliseconds; not elapsed ringing time or proof of billed time."
              },
              "created_at": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Creation time when retained.",
                "format": "date-time"
              },
              "start_timestamp": {
                "type": [
                  "integer",
                  "null"
                ],
                "description": "Start time in Unix milliseconds."
              },
              "end_timestamp": {
                "type": [
                  "integer",
                  "null"
                ],
                "description": "End time in Unix milliseconds."
              },
              "answered_at": {
                "type": [
                  "integer",
                  "null"
                ],
                "description": "Answer time in Unix milliseconds, when known."
              },
              "ended_reason": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Recorded end/failure reason. A null value is unknown, not success."
              },
              "call_successful": {
                "type": [
                  "boolean",
                  "null"
                ],
                "description": "Assessment of success. Null means unknown."
              },
              "caller_sentiment": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Post-call sentiment, if retained."
              },
              "cost": {
                "type": [
                  "number",
                  "null"
                ],
                "description": "Stored cost value. Null must remain unknown."
              },
              "charged_minutes": {
                "type": [
                  "number",
                  "null"
                ],
                "description": "Stored charged-minute value, when known."
              },
              "campaign_id": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Associated campaign, if any."
              },
              "test_requested_by": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Retained test source marker, if any."
              },
              "caller_name": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Caller name, if retained."
              },
              "payload_deleted_at": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Time content was erased.",
                "format": "date-time"
              },
              "payload_deleted_reason": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Recorded erasure reason."
              },
              "payload_in_own_storage": {
                "type": [
                  "boolean",
                  "null"
                ],
                "description": "Whether payload was stored in account-connected storage; its current contents are not inspected."
              },
              "call_retention_days": {
                "type": [
                  "integer",
                  "null"
                ],
                "description": "Retention policy recorded for this call."
              },
              "payload_scheduled_for_deletion": {
                "type": "boolean",
                "description": "Content is hidden while deletion processing finishes."
              },
              "call_summary": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Retained summary; can be absent or null."
              },
              "transcript": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Retained transcript; hidden/erased content is null."
              },
              "extracted_data": {
                "description": "Retained extracted JSON data, or null."
              },
              "call_events": {
                "description": "Retained event JSON data, or null."
              },
              "recording_url": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Legacy recording pointer. Prefer the recording endpoint; detail view always returns null."
              },
              "recording_status": {
                "type": "string",
                "description": "Recording availability state when supplied."
              },
              "recording_endpoint": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Optional API path for a recording read; not itself a download URL."
              },
              "recording_availability": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Stored recording processing state."
              },
              "recording_availability_reason": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Stored recording processing reason."
              }
            },
            "required": [
              "call_id"
            ],
            "description": "Legacy call rows can include additional fields. Availability varies with retention and lifecycle.",
            "additionalProperties": true
          },
          "description": "Legacy list response."
        },
        {
          "type": "object",
          "properties": {
            "data": {
              "type": "array",
              "items": {
                "type": "object",
                "properties": {
                  "call_id": {
                    "type": "string",
                    "description": "Call identifier. Failed starts can use the failed: prefix."
                  },
                  "id": {
                    "type": "string",
                    "description": "Internal row identifier when present.",
                    "format": "uuid"
                  },
                  "agent_id": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "description": "Agent identifier, if retained."
                  },
                  "from_number": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "description": "Origin number, if retained."
                  },
                  "to_number": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "description": "Destination number, if retained."
                  },
                  "call_type": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "description": "Call channel/type, such as inbound, outbound or web."
                  },
                  "call_direction": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "description": "Direction recorded for the call."
                  },
                  "call_status": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "description": "Recorded lifecycle state; unknown future states must be tolerated."
                  },
                  "duration_ms": {
                    "type": [
                      "integer",
                      "null"
                    ],
                    "description": "Connected duration in milliseconds; not elapsed ringing time or proof of billed time."
                  },
                  "created_at": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "description": "Creation time when retained.",
                    "format": "date-time"
                  },
                  "start_timestamp": {
                    "type": [
                      "integer",
                      "null"
                    ],
                    "description": "Start time in Unix milliseconds."
                  },
                  "end_timestamp": {
                    "type": [
                      "integer",
                      "null"
                    ],
                    "description": "End time in Unix milliseconds."
                  },
                  "answered_at": {
                    "type": [
                      "integer",
                      "null"
                    ],
                    "description": "Answer time in Unix milliseconds, when known."
                  },
                  "ended_reason": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "description": "Recorded end/failure reason. A null value is unknown, not success."
                  },
                  "call_successful": {
                    "type": [
                      "boolean",
                      "null"
                    ],
                    "description": "Assessment of success. Null means unknown."
                  },
                  "caller_sentiment": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "description": "Post-call sentiment, if retained."
                  },
                  "cost": {
                    "type": [
                      "number",
                      "null"
                    ],
                    "description": "Stored cost value. Null must remain unknown."
                  },
                  "charged_minutes": {
                    "type": [
                      "number",
                      "null"
                    ],
                    "description": "Stored charged-minute value, when known."
                  },
                  "campaign_id": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "description": "Associated campaign, if any."
                  },
                  "test_requested_by": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "description": "Retained test source marker, if any."
                  },
                  "caller_name": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "description": "Caller name, if retained."
                  },
                  "payload_deleted_at": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "description": "Time content was erased.",
                    "format": "date-time"
                  },
                  "payload_deleted_reason": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "description": "Recorded erasure reason."
                  },
                  "payload_in_own_storage": {
                    "type": [
                      "boolean",
                      "null"
                    ],
                    "description": "Whether payload was stored in account-connected storage; its current contents are not inspected."
                  },
                  "call_retention_days": {
                    "type": [
                      "integer",
                      "null"
                    ],
                    "description": "Retention policy recorded for this call."
                  },
                  "payload_scheduled_for_deletion": {
                    "type": "boolean",
                    "description": "Content is hidden while deletion processing finishes."
                  },
                  "call_summary": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "description": "Retained summary; can be absent or null."
                  },
                  "recording_availability": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "description": "Stored recording processing state."
                  },
                  "recording_availability_reason": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "description": "Stored recording processing reason."
                  }
                },
                "required": [
                  "call_id"
                ],
                "description": "Call metadata and any retained summary. Transcript, event data, extracted data and recording URLs are omitted.",
                "additionalProperties": true
              },
              "description": "Page of matching retained call metadata."
            },
            "totals": {
              "type": "object",
              "properties": {
                "total": {
                  "type": "integer",
                  "description": "All matching retained rows, not just this page.",
                  "minimum": 0
                },
                "minutes": {
                  "type": "number",
                  "description": "Sum of nonnegative connected durations divided by 60,000."
                },
                "cost": {
                  "type": "number",
                  "description": "Sum of known stored costs; unknown costs are counted separately."
                },
                "cost_unknown": {
                  "type": "integer",
                  "description": "Matching rows whose cost is unknown.",
                  "minimum": 0
                },
                "successful": {
                  "type": "integer",
                  "description": "Matching rows whose success flag is true.",
                  "minimum": 0
                }
              },
              "required": [
                "total",
                "minutes",
                "cost",
                "cost_unknown",
                "successful"
              ],
              "description": "",
              "additionalProperties": false
            },
            "filters": {
              "type": "object",
              "properties": {
                "direction": {
                  "type": "string",
                  "description": "Filter by direction.",
                  "enum": [
                    "all",
                    "inbound",
                    "outbound",
                    "web"
                  ],
                  "default": "all"
                },
                "source": {
                  "type": "string",
                  "description": "Filter by source.",
                  "enum": [
                    "all",
                    "campaign",
                    "web",
                    "test",
                    "other"
                  ],
                  "default": "all"
                },
                "outcome": {
                  "type": "string",
                  "description": "Filter by outcome.",
                  "enum": [
                    "all",
                    "successful",
                    "unsuccessful",
                    "unknown",
                    "failed"
                  ],
                  "default": "all"
                },
                "period": {
                  "type": "string",
                  "description": "UTC time range: today starts at UTC midnight; week is the preceding 7 days; month the preceding 30 days.",
                  "enum": [
                    "all",
                    "today",
                    "week",
                    "month"
                  ],
                  "default": "month"
                },
                "agent": {
                  "type": "string",
                  "description": "Agent ID, or all. This is agent, not agent_id.",
                  "maxLength": 200,
                  "default": "all"
                },
                "number": {
                  "type": "string",
                  "description": "Business number, or all; use + in E.164 and encode it in the query.",
                  "maxLength": 80,
                  "default": "all"
                },
                "search": {
                  "type": "string",
                  "description": "Trimmed literal search in caller name, call ID and phone numbers. Control characters are invalid.",
                  "maxLength": 120,
                  "default": ""
                },
                "since": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "description": "Optional ISO timestamp with a time zone. Overrides the period start; must not be after until.",
                  "format": "date-time",
                  "maxLength": 40
                },
                "until": {
                  "type": "string",
                  "description": "Optional ISO timestamp with a time zone; defaults to request time.",
                  "format": "date-time",
                  "maxLength": 40
                }
              },
              "required": [
                "direction",
                "source",
                "outcome",
                "period",
                "agent",
                "number",
                "search",
                "since",
                "until"
              ],
              "description": "",
              "additionalProperties": false
            },
            "limit": {
              "type": "integer",
              "description": "Applied page limit."
            },
            "offset": {
              "type": "integer",
              "description": "Applied offset; zero during cursor continuation."
            },
            "has_more": {
              "type": "boolean",
              "description": "Whether another page exists."
            },
            "next_cursor": {
              "type": [
                "string",
                "null"
              ],
              "description": "Opaque continuation, or null at the end."
            }
          },
          "required": [
            "data",
            "totals",
            "filters",
            "limit",
            "offset",
            "has_more",
            "next_cursor"
          ],
          "description": "",
          "additionalProperties": false
        }
      ]
    }
  },
  {
    "number": 87,
    "method": "GET",
    "path": "/v1/calls/:id",
    "query": "?view=detail",
    "schema": {
      "anyOf": [
        {
          "type": "object",
          "properties": {
            "call_id": {
              "type": "string",
              "description": "Call identifier. Failed starts can use the failed: prefix."
            },
            "id": {
              "type": "string",
              "description": "Internal row identifier when present.",
              "format": "uuid"
            },
            "agent_id": {
              "type": [
                "string",
                "null"
              ],
              "description": "Agent identifier, if retained."
            },
            "from_number": {
              "type": [
                "string",
                "null"
              ],
              "description": "Origin number, if retained."
            },
            "to_number": {
              "type": [
                "string",
                "null"
              ],
              "description": "Destination number, if retained."
            },
            "call_type": {
              "type": [
                "string",
                "null"
              ],
              "description": "Call channel/type, such as inbound, outbound or web."
            },
            "call_direction": {
              "type": [
                "string",
                "null"
              ],
              "description": "Direction recorded for the call."
            },
            "call_status": {
              "type": [
                "string",
                "null"
              ],
              "description": "Recorded lifecycle state; unknown future states must be tolerated."
            },
            "duration_ms": {
              "type": [
                "integer",
                "null"
              ],
              "description": "Connected duration in milliseconds; not elapsed ringing time or proof of billed time."
            },
            "created_at": {
              "type": [
                "string",
                "null"
              ],
              "description": "Creation time when retained.",
              "format": "date-time"
            },
            "start_timestamp": {
              "type": [
                "integer",
                "null"
              ],
              "description": "Start time in Unix milliseconds."
            },
            "end_timestamp": {
              "type": [
                "integer",
                "null"
              ],
              "description": "End time in Unix milliseconds."
            },
            "answered_at": {
              "type": [
                "integer",
                "null"
              ],
              "description": "Answer time in Unix milliseconds, when known."
            },
            "ended_reason": {
              "type": [
                "string",
                "null"
              ],
              "description": "Recorded end/failure reason. A null value is unknown, not success."
            },
            "call_successful": {
              "type": [
                "boolean",
                "null"
              ],
              "description": "Assessment of success. Null means unknown."
            },
            "caller_sentiment": {
              "type": [
                "string",
                "null"
              ],
              "description": "Post-call sentiment, if retained."
            },
            "cost": {
              "type": [
                "number",
                "null"
              ],
              "description": "Stored cost value. Null must remain unknown."
            },
            "charged_minutes": {
              "type": [
                "number",
                "null"
              ],
              "description": "Stored charged-minute value, when known."
            },
            "campaign_id": {
              "type": [
                "string",
                "null"
              ],
              "description": "Associated campaign, if any."
            },
            "test_requested_by": {
              "type": [
                "string",
                "null"
              ],
              "description": "Retained test source marker, if any."
            },
            "caller_name": {
              "type": [
                "string",
                "null"
              ],
              "description": "Caller name, if retained."
            },
            "payload_deleted_at": {
              "type": [
                "string",
                "null"
              ],
              "description": "Time content was erased.",
              "format": "date-time"
            },
            "payload_deleted_reason": {
              "type": [
                "string",
                "null"
              ],
              "description": "Recorded erasure reason."
            },
            "payload_in_own_storage": {
              "type": [
                "boolean",
                "null"
              ],
              "description": "Whether payload was stored in account-connected storage; its current contents are not inspected."
            },
            "call_retention_days": {
              "type": [
                "integer",
                "null"
              ],
              "description": "Retention policy recorded for this call."
            },
            "payload_scheduled_for_deletion": {
              "type": "boolean",
              "description": "Content is hidden while deletion processing finishes."
            },
            "call_summary": {
              "type": [
                "string",
                "null"
              ],
              "description": "Retained summary; can be absent or null."
            },
            "transcript": {
              "type": [
                "string",
                "null"
              ],
              "description": "Retained transcript; hidden/erased content is null."
            },
            "extracted_data": {
              "description": "Retained extracted JSON data, or null."
            },
            "call_events": {
              "description": "Retained event JSON data, or null."
            },
            "recording_url": {
              "type": [
                "string",
                "null"
              ],
              "description": "Legacy recording pointer. Prefer the recording endpoint; detail view always returns null."
            },
            "recording_status": {
              "type": "string",
              "description": "Recording availability state when supplied."
            },
            "recording_endpoint": {
              "type": [
                "string",
                "null"
              ],
              "description": "Optional API path for a recording read; not itself a download URL."
            },
            "recording_availability": {
              "type": [
                "string",
                "null"
              ],
              "description": "Stored recording processing state."
            },
            "recording_availability_reason": {
              "type": [
                "string",
                "null"
              ],
              "description": "Stored recording processing reason."
            }
          },
          "required": [
            "call_id"
          ],
          "description": "Legacy call rows can include additional fields. Availability varies with retention and lifecycle.",
          "additionalProperties": true
        },
        {
          "type": "object",
          "properties": {
            "call_id": {
              "type": "string",
              "description": "Call identifier. Failed starts can use the failed: prefix."
            },
            "id": {
              "type": "string",
              "description": "Internal row identifier when present.",
              "format": "uuid"
            },
            "agent_id": {
              "type": [
                "string",
                "null"
              ],
              "description": "Agent identifier, if retained."
            },
            "from_number": {
              "type": [
                "string",
                "null"
              ],
              "description": "Origin number, if retained."
            },
            "to_number": {
              "type": [
                "string",
                "null"
              ],
              "description": "Destination number, if retained."
            },
            "call_type": {
              "type": [
                "string",
                "null"
              ],
              "description": "Call channel/type, such as inbound, outbound or web."
            },
            "call_direction": {
              "type": [
                "string",
                "null"
              ],
              "description": "Direction recorded for the call."
            },
            "call_status": {
              "type": [
                "string",
                "null"
              ],
              "description": "Recorded lifecycle state; unknown future states must be tolerated."
            },
            "duration_ms": {
              "type": [
                "integer",
                "null"
              ],
              "description": "Connected duration in milliseconds; not elapsed ringing time or proof of billed time."
            },
            "created_at": {
              "type": [
                "string",
                "null"
              ],
              "description": "Creation time when retained.",
              "format": "date-time"
            },
            "start_timestamp": {
              "type": [
                "integer",
                "null"
              ],
              "description": "Start time in Unix milliseconds."
            },
            "end_timestamp": {
              "type": [
                "integer",
                "null"
              ],
              "description": "End time in Unix milliseconds."
            },
            "answered_at": {
              "type": [
                "integer",
                "null"
              ],
              "description": "Answer time in Unix milliseconds, when known."
            },
            "ended_reason": {
              "type": [
                "string",
                "null"
              ],
              "description": "Recorded end/failure reason. A null value is unknown, not success."
            },
            "call_successful": {
              "type": [
                "boolean",
                "null"
              ],
              "description": "Assessment of success. Null means unknown."
            },
            "caller_sentiment": {
              "type": [
                "string",
                "null"
              ],
              "description": "Post-call sentiment, if retained."
            },
            "cost": {
              "type": [
                "number",
                "null"
              ],
              "description": "Stored cost value. Null must remain unknown."
            },
            "charged_minutes": {
              "type": [
                "number",
                "null"
              ],
              "description": "Stored charged-minute value, when known."
            },
            "campaign_id": {
              "type": [
                "string",
                "null"
              ],
              "description": "Associated campaign, if any."
            },
            "test_requested_by": {
              "type": [
                "string",
                "null"
              ],
              "description": "Retained test source marker, if any."
            },
            "caller_name": {
              "type": [
                "string",
                "null"
              ],
              "description": "Caller name, if retained."
            },
            "payload_deleted_at": {
              "type": [
                "string",
                "null"
              ],
              "description": "Time content was erased.",
              "format": "date-time"
            },
            "payload_deleted_reason": {
              "type": [
                "string",
                "null"
              ],
              "description": "Recorded erasure reason."
            },
            "payload_in_own_storage": {
              "type": [
                "boolean",
                "null"
              ],
              "description": "Whether payload was stored in account-connected storage; its current contents are not inspected."
            },
            "call_retention_days": {
              "type": [
                "integer",
                "null"
              ],
              "description": "Retention policy recorded for this call."
            },
            "payload_scheduled_for_deletion": {
              "type": "boolean",
              "description": "Content is hidden while deletion processing finishes."
            },
            "call_summary": {
              "type": [
                "string",
                "null"
              ],
              "description": "Retained summary; can be absent or null."
            },
            "transcript": {
              "type": [
                "string",
                "null"
              ],
              "description": "Retained transcript; hidden/erased content is null."
            },
            "extracted_data": {
              "description": "Retained extracted JSON data, or null."
            },
            "call_events": {
              "description": "Retained event JSON data, or null."
            },
            "recording_url": {
              "type": "null",
              "description": "Detail view never returns a raw recording URL. Use Get a call recording."
            },
            "recording_status": {
              "type": "string",
              "description": "Recording availability state when supplied."
            },
            "recording_availability": {
              "type": [
                "string",
                "null"
              ],
              "description": "Stored recording processing state."
            },
            "recording_availability_reason": {
              "type": [
                "string",
                "null"
              ],
              "description": "Stored recording processing reason."
            }
          },
          "required": [
            "call_id"
          ],
          "description": "Detail reads include failed starts and retained metadata stubs. Fields can be omitted on stubs; null does not mean zero or success.",
          "additionalProperties": true
        }
      ]
    }
  },
  {
    "number": 89,
    "method": "GET",
    "path": "/v1/calls/:id/recording",
    "query": "",
    "schema": {
      "type": "object",
      "properties": {
        "call_id": {
          "type": "string",
          "description": "The requested call ID."
        },
        "status": {
          "type": "string",
          "description": "available has a signed URL; other states do not.",
          "enum": [
            "available",
            "pending",
            "expired",
            "customer_bucket",
            "not_recorded",
            "pending_deletion",
            "unavailable",
            "unknown"
          ]
        },
        "url": {
          "type": [
            "string",
            "null"
          ],
          "description": "Short-lived download URL only when available. Treat it as a bearer credential and do not log it."
        },
        "expires_at": {
          "type": [
            "string",
            "null"
          ],
          "description": "Expiry of the returned signed URL, or null.",
          "format": "date-time"
        }
      },
      "required": [
        "call_id",
        "status",
        "url",
        "expires_at"
      ],
      "description": "",
      "additionalProperties": false
    }
  },
  {
    "number": 95,
    "method": "GET",
    "path": "/v1/calls/history",
    "query": "?period=all&limit=20",
    "schema": {
      "type": "object",
      "properties": {
        "data": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "call_id": {
                "type": "string",
                "description": "Call identifier. Failed starts can use the failed: prefix."
              },
              "id": {
                "type": "string",
                "description": "Internal row identifier when present.",
                "format": "uuid"
              },
              "agent_id": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Agent identifier, if retained."
              },
              "from_number": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Origin number, if retained."
              },
              "to_number": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Destination number, if retained."
              },
              "call_type": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Call channel/type, such as inbound, outbound or web."
              },
              "call_direction": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Direction recorded for the call."
              },
              "call_status": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Recorded lifecycle state; unknown future states must be tolerated."
              },
              "duration_ms": {
                "type": [
                  "integer",
                  "null"
                ],
                "description": "Connected duration in milliseconds; not elapsed ringing time or proof of billed time."
              },
              "created_at": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Creation time when retained.",
                "format": "date-time"
              },
              "start_timestamp": {
                "type": [
                  "integer",
                  "null"
                ],
                "description": "Start time in Unix milliseconds."
              },
              "end_timestamp": {
                "type": [
                  "integer",
                  "null"
                ],
                "description": "End time in Unix milliseconds."
              },
              "answered_at": {
                "type": [
                  "integer",
                  "null"
                ],
                "description": "Answer time in Unix milliseconds, when known."
              },
              "ended_reason": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Recorded end/failure reason. A null value is unknown, not success."
              },
              "call_successful": {
                "type": [
                  "boolean",
                  "null"
                ],
                "description": "Assessment of success. Null means unknown."
              },
              "caller_sentiment": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Post-call sentiment, if retained."
              },
              "cost": {
                "type": [
                  "number",
                  "null"
                ],
                "description": "Stored cost value. Null must remain unknown."
              },
              "charged_minutes": {
                "type": [
                  "number",
                  "null"
                ],
                "description": "Stored charged-minute value, when known."
              },
              "campaign_id": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Associated campaign, if any."
              },
              "test_requested_by": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Retained test source marker, if any."
              },
              "caller_name": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Caller name, if retained."
              },
              "payload_deleted_at": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Time content was erased.",
                "format": "date-time"
              },
              "payload_deleted_reason": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Recorded erasure reason."
              },
              "payload_in_own_storage": {
                "type": [
                  "boolean",
                  "null"
                ],
                "description": "Whether payload was stored in account-connected storage; its current contents are not inspected."
              },
              "call_retention_days": {
                "type": [
                  "integer",
                  "null"
                ],
                "description": "Retention policy recorded for this call."
              },
              "payload_scheduled_for_deletion": {
                "type": "boolean",
                "description": "Content is hidden while deletion processing finishes."
              },
              "call_summary": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Retained summary; can be absent or null."
              },
              "recording_availability": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Stored recording processing state."
              },
              "recording_availability_reason": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Stored recording processing reason."
              }
            },
            "required": [
              "call_id"
            ],
            "description": "Call metadata and any retained summary. Transcript, event data, extracted data and recording URLs are omitted.",
            "additionalProperties": true
          },
          "description": "Page of matching retained call metadata."
        },
        "totals": {
          "type": "object",
          "properties": {
            "total": {
              "type": "integer",
              "description": "All matching retained rows, not just this page.",
              "minimum": 0
            },
            "minutes": {
              "type": "number",
              "description": "Sum of nonnegative connected durations divided by 60,000."
            },
            "cost": {
              "type": "number",
              "description": "Sum of known stored costs; unknown costs are counted separately."
            },
            "cost_unknown": {
              "type": "integer",
              "description": "Matching rows whose cost is unknown.",
              "minimum": 0
            },
            "successful": {
              "type": "integer",
              "description": "Matching rows whose success flag is true.",
              "minimum": 0
            }
          },
          "required": [
            "total",
            "minutes",
            "cost",
            "cost_unknown",
            "successful"
          ],
          "description": "",
          "additionalProperties": false
        },
        "filters": {
          "type": "object",
          "properties": {
            "direction": {
              "type": "string",
              "description": "Filter by direction.",
              "enum": [
                "all",
                "inbound",
                "outbound",
                "web"
              ],
              "default": "all"
            },
            "source": {
              "type": "string",
              "description": "Filter by source.",
              "enum": [
                "all",
                "campaign",
                "web",
                "test",
                "other"
              ],
              "default": "all"
            },
            "outcome": {
              "type": "string",
              "description": "Filter by outcome.",
              "enum": [
                "all",
                "successful",
                "unsuccessful",
                "unknown",
                "failed"
              ],
              "default": "all"
            },
            "period": {
              "type": "string",
              "description": "UTC time range: today starts at UTC midnight; week is the preceding 7 days; month the preceding 30 days.",
              "enum": [
                "all",
                "today",
                "week",
                "month"
              ],
              "default": "month"
            },
            "agent": {
              "type": "string",
              "description": "Agent ID, or all. This is agent, not agent_id.",
              "maxLength": 200,
              "default": "all"
            },
            "number": {
              "type": "string",
              "description": "Business number, or all; use + in E.164 and encode it in the query.",
              "maxLength": 80,
              "default": "all"
            },
            "search": {
              "type": "string",
              "description": "Trimmed literal search in caller name, call ID and phone numbers. Control characters are invalid.",
              "maxLength": 120,
              "default": ""
            },
            "since": {
              "type": [
                "string",
                "null"
              ],
              "description": "Optional ISO timestamp with a time zone. Overrides the period start; must not be after until.",
              "format": "date-time",
              "maxLength": 40
            },
            "until": {
              "type": "string",
              "description": "Optional ISO timestamp with a time zone; defaults to request time.",
              "format": "date-time",
              "maxLength": 40
            }
          },
          "required": [
            "direction",
            "source",
            "outcome",
            "period",
            "agent",
            "number",
            "search",
            "since",
            "until"
          ],
          "description": "",
          "additionalProperties": false
        },
        "limit": {
          "type": "integer",
          "description": "Applied page limit."
        },
        "offset": {
          "type": "integer",
          "description": "Applied offset; zero during cursor continuation."
        },
        "has_more": {
          "type": "boolean",
          "description": "Whether another page exists."
        },
        "next_cursor": {
          "type": [
            "string",
            "null"
          ],
          "description": "Opaque continuation, or null at the end."
        }
      },
      "required": [
        "data",
        "totals",
        "filters",
        "limit",
        "offset",
        "has_more",
        "next_cursor"
      ],
      "description": "",
      "additionalProperties": false
    }
  },
  {
    "number": 97,
    "method": "GET",
    "path": "/v1/campaigns",
    "query": "?limit=2",
    "schema": {
      "type": "object",
      "properties": {
        "campaigns": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "campaign_id": {
                "type": "string",
                "description": "Public campaign ID."
              },
              "agent_id": {
                "type": "string",
                "description": "Owning agent ID."
              },
              "name": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Saved campaign label."
              },
              "from_number": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "International number with + and digits; no spaces.",
                "pattern": "^\\+[1-9][0-9]{6,14}$"
              },
              "schedule_type": {
                "type": "string",
                "description": "Saved now or schedule mode."
              },
              "scheduled_date": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Saved scheduled date."
              },
              "window_start_minutes": {
                "type": [
                  "integer",
                  "null"
                ],
                "description": "Configured start minute."
              },
              "window_end_minutes": {
                "type": [
                  "integer",
                  "null"
                ],
                "description": "Configured end minute."
              },
              "window_days": {
                "type": [
                  "array",
                  "null"
                ],
                "items": {
                  "type": "string",
                  "description": "Weekday."
                },
                "description": ""
              },
              "timezone": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Saved campaign time zone."
              },
              "source": {
                "type": "string",
                "description": "Saved origin label."
              },
              "status": {
                "type": "string",
                "description": "Current state; for example scheduled, launching, running, done, failed or cancelled. Treat new states conservatively."
              },
              "total_count": {
                "type": "integer",
                "description": "Count.",
                "minimum": 0
              },
              "started_at": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Saved timestamp, or null.",
                "format": "date-time"
              },
              "completed_at": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Saved timestamp, or null.",
                "format": "date-time"
              },
              "created_at": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Saved timestamp, or null.",
                "format": "date-time"
              },
              "updated_at": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Saved timestamp, or null.",
                "format": "date-time"
              },
              "allow_wider_hours": {
                "type": "boolean",
                "description": "True only with confirmation evidence for the current policy revision."
              },
              "prompt": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Default voice instructions."
              },
              "done_count": {
                "type": "integer",
                "description": "Count.",
                "minimum": 0
              },
              "failed_count": {
                "type": "integer",
                "description": "Count.",
                "minimum": 0
              },
              "voicemail_count": {
                "type": "integer",
                "description": "Count.",
                "minimum": 0
              }
            },
            "required": [
              "campaign_id",
              "agent_id",
              "name",
              "from_number",
              "schedule_type",
              "scheduled_date",
              "window_start_minutes",
              "window_end_minutes",
              "window_days",
              "timezone",
              "source",
              "status",
              "total_count",
              "started_at",
              "completed_at",
              "created_at",
              "updated_at",
              "allow_wider_hours",
              "prompt",
              "done_count",
              "failed_count",
              "voicemail_count"
            ],
            "description": "",
            "additionalProperties": false
          },
          "description": ""
        }
      },
      "required": [
        "campaigns"
      ],
      "description": "",
      "additionalProperties": false
    }
  },
  {
    "number": 100,
    "method": "GET",
    "path": "/v1/contact-suppressions",
    "query": "?channel=all",
    "schema": {
      "type": "object",
      "properties": {
        "entries": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "phone_number": {
                "type": "string",
                "description": "International number with + and digits; no spaces.",
                "pattern": "^\\+[1-9][0-9]{6,14}$"
              },
              "channel": {
                "type": "string",
                "description": "Stored channel bucket.",
                "enum": [
                  "all",
                  "voice",
                  "sms"
                ]
              },
              "source": {
                "type": "string",
                "description": "Why it was suppressed, for example owner or sms_optout."
              },
              "created_at": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Saved timestamp, or null.",
                "format": "date-time"
              },
              "removal_locked": {
                "type": "boolean",
                "description": "Only false for an explicitly removable owner-created entry."
              },
              "opted_out_message": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "For SMS opt-outs: retained text, limited to 160 code points."
              },
              "opted_out_at": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Saved timestamp, or null.",
                "format": "date-time"
              },
              "opted_out_business_number": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "International number with + and digits; no spaces.",
                "pattern": "^\\+[1-9][0-9]{6,14}$"
              }
            },
            "required": [
              "phone_number",
              "channel",
              "source",
              "created_at",
              "removal_locked"
            ],
            "description": "",
            "additionalProperties": false
          },
          "description": ""
        },
        "next_cursor": {
          "type": [
            "string",
            "null"
          ],
          "description": "International number with + and digits; no spaces.",
          "pattern": "^\\+[1-9][0-9]{6,14}$"
        }
      },
      "required": [
        "entries",
        "next_cursor"
      ],
      "description": "",
      "additionalProperties": false
    }
  },
  {
    "number": 102,
    "method": "GET",
    "path": "/v1/keys/activity",
    "query": "?period=7d",
    "schema": {
      "type": "object",
      "properties": {
        "period": {
          "type": "string",
          "description": "Selected UTC reporting period.",
          "enum": [
            "today",
            "7d"
          ]
        },
        "timezone": {
          "type": "string",
          "description": "Reporting time zone.",
          "const": "UTC"
        },
        "requests": {
          "type": "integer",
          "description": "Retained requests in the chosen period.",
          "minimum": 0
        },
        "errors": {
          "type": "integer",
          "description": "Retained error responses in the chosen period.",
          "minimum": 0
        },
        "requests_today": {
          "type": "integer",
          "description": "Retained requests since the current UTC midnight.",
          "minimum": 0
        },
        "errors_today": {
          "type": "integer",
          "description": "Retained error responses since the current UTC midnight.",
          "minimum": 0
        },
        "day_start": {
          "type": "string",
          "description": "Current UTC day start.",
          "format": "date-time"
        },
        "period_start": {
          "type": "string",
          "description": "Beginning of the selected reporting interval.",
          "format": "date-time"
        },
        "as_of": {
          "type": "string",
          "description": "Snapshot time for these counts.",
          "format": "date-time"
        },
        "last_used_at": {
          "type": [
            "string",
            "null"
          ],
          "description": "Last retained request time, or null.",
          "format": "date-time"
        },
        "top_endpoints": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "method": {
                "type": "string",
                "description": "HTTP method."
              },
              "endpoint": {
                "type": "string",
                "description": "Recorded endpoint label."
              },
              "requests": {
                "type": "integer",
                "description": "Retained request count.",
                "minimum": 0
              }
            },
            "required": [
              "method",
              "endpoint",
              "requests"
            ],
            "description": "",
            "additionalProperties": false
          },
          "description": "Up to five busiest endpoint/method pairs.",
          "maxItems": 5
        }
      },
      "required": [
        "period",
        "timezone",
        "requests",
        "errors",
        "requests_today",
        "errors_today",
        "day_start",
        "period_start",
        "as_of",
        "last_used_at",
        "top_endpoints"
      ],
      "description": "",
      "additionalProperties": false
    }
  },
  {
    "number": 103,
    "method": "GET",
    "path": "/v1/knowledge-bases/:kb",
    "query": "",
    "schema": {
      "type": "object",
      "properties": {
        "id": {
          "type": "string",
          "description": "Opaque identifier. Keep it as a string.",
          "format": "uuid"
        },
        "owner": {
          "type": "string",
          "description": "Owning account identifier; it never grants access when sent by a caller."
        },
        "kind": {
          "type": "string",
          "description": "Knowledge belongs to an agent.",
          "const": "agent"
        },
        "target": {
          "type": "string",
          "description": "Owning agent ID."
        },
        "rev": {
          "type": "integer",
          "description": "Latest integer revision read from this resource; it must still match when the request runs.",
          "minimum": 1
        },
        "active": {
          "type": [
            "string",
            "null"
          ],
          "description": "Active published index revision, or null before publication.",
          "format": "uuid"
        },
        "state": {
          "type": "string",
          "description": "Lifecycle state.",
          "enum": [
            "ready",
            "deleting",
            "deleted"
          ]
        },
        "settings": {
          "type": "object",
          "properties": {
            "channels": {
              "type": "array",
              "items": {
                "type": "string",
                "description": "Channel identifier.",
                "enum": [
                  "inbound",
                  "outbound",
                  "web_voice",
                  "web_chat",
                  "sms"
                ]
              },
              "description": "Enabled knowledge channels. An empty list turns knowledge off for all channels.",
              "uniqueItems": true,
              "default": [
                "inbound"
              ]
            },
            "match": {
              "type": "string",
              "description": "Answer matching mode.",
              "enum": [
                "Strict",
                "Normal"
              ],
              "default": "Strict"
            },
            "not_found": {
              "type": "string",
              "description": "Nonblank response when suitable knowledge is missing.",
              "minLength": 1,
              "maxLength": 500,
              "default": "I don't have that information right now."
            }
          },
          "additionalProperties": false,
          "description": "Only channels, match and not_found may be supplied. Omitted settings retain the saved value on update."
        },
        "tombstones": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "id": {
                "type": "string",
                "description": "Opaque identifier. Keep it as a string.",
                "format": "uuid"
              },
              "subject_hash": {
                "type": "string",
                "description": "Normalized title digest."
              },
              "evidence": {
                "type": "array",
                "items": {
                  "type": "object",
                  "properties": {
                    "source": {
                      "type": "string",
                      "description": "Opaque identifier. Keep it as a string.",
                      "format": "uuid"
                    },
                    "segment": {
                      "type": "integer",
                      "description": "Source segment index."
                    },
                    "quote": {
                      "type": "string",
                      "description": "Original evidence text."
                    },
                    "quote_hash": {
                      "type": "string",
                      "description": "Digest used by a deletion record."
                    },
                    "topic_id": {
                      "type": "string",
                      "description": "Opaque identifier. Keep it as a string.",
                      "format": "uuid"
                    },
                    "revision": {
                      "type": "string",
                      "description": "Opaque identifier. Keep it as a string.",
                      "format": "uuid"
                    },
                    "title": {
                      "type": "string",
                      "description": "Title snapshot at answer time."
                    }
                  },
                  "additionalProperties": true,
                  "description": "Evidence fields vary by source, topic or answer. IDs identify supplied context, not proof that every piece affected an answer."
                },
                "description": ""
              }
            },
            "required": [
              "id",
              "subject_hash",
              "evidence"
            ],
            "additionalProperties": true,
            "description": ""
          },
          "description": "Records that prevent refreshed sources restoring removed pieces."
        },
        "created_at": {
          "type": "string",
          "description": "UTC timestamp.",
          "format": "date-time"
        }
      },
      "required": [
        "id",
        "owner",
        "kind",
        "target",
        "rev",
        "active",
        "state",
        "settings",
        "tombstones",
        "created_at"
      ],
      "additionalProperties": true,
      "description": ""
    }
  },
  {
    "number": 109,
    "method": "GET",
    "path": "/v1/knowledge-bases/:kb/overview",
    "query": "",
    "schema": {
      "type": "object",
      "properties": {
        "topics": {
          "type": "integer",
          "description": ""
        },
        "tokens": {
          "type": "integer",
          "description": "Packed current live topic tokens."
        },
        "used_tokens": {
          "type": "integer",
          "description": "Original-source tokens plus additional manual text."
        },
        "answers": {
          "type": "integer",
          "description": "Recorded knowledge-supplied delivered turns over seven days."
        },
        "missing": {
          "type": "integer",
          "description": "Recorded delivered turns with no retrieval match over seven days."
        },
        "last_updated": {
          "type": "string",
          "description": "UTC timestamp.",
          "format": "date-time"
        },
        "review": {
          "type": [
            "object",
            "null"
          ],
          "properties": {
            "id": {
              "type": "string",
              "description": "Opaque identifier. Keep it as a string.",
              "format": "uuid"
            },
            "count": {
              "type": "integer",
              "description": ""
            }
          },
          "required": [
            "id",
            "count"
          ],
          "additionalProperties": true,
          "description": ""
        }
      },
      "required": [
        "topics",
        "tokens",
        "used_tokens",
        "answers",
        "missing",
        "last_updated",
        "review"
      ],
      "additionalProperties": true,
      "description": ""
    }
  },
  {
    "number": 111,
    "method": "GET",
    "path": "/v1/knowledge-bases/:kb/sources",
    "query": "?limit=2",
    "schema": {
      "type": "object",
      "properties": {
        "items": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "id": {
                "type": "string",
                "description": "Opaque identifier. Keep it as a string.",
                "format": "uuid"
              },
              "revision": {
                "type": "integer",
                "description": "Latest integer revision read from this resource; it must still match when the request runs.",
                "minimum": 1
              },
              "title": {
                "type": "string",
                "description": "Saved source title."
              },
              "type": {
                "type": "string",
                "description": "Stored source type.",
                "enum": [
                  "text",
                  "file",
                  "url"
                ]
              },
              "url": {
                "type": "string",
                "description": "Present for website pages; private source location."
              },
              "tokens": {
                "type": "integer",
                "description": "Original source token count."
              },
              "created_at": {
                "type": "string",
                "description": "UTC timestamp.",
                "format": "date-time"
              },
              "topic_count": {
                "type": "integer",
                "description": "Unsuppressed live pieces linked to this source."
              }
            },
            "required": [
              "id",
              "revision",
              "title",
              "type",
              "created_at"
            ],
            "additionalProperties": true,
            "description": ""
          },
          "description": ""
        },
        "next_cursor": {
          "type": [
            "string",
            "null"
          ],
          "description": "Opaque cursor. Send it unchanged for the next page; null ends this list."
        }
      },
      "required": [
        "items",
        "next_cursor"
      ],
      "additionalProperties": true,
      "description": ""
    }
  },
  {
    "number": 118,
    "method": "GET",
    "path": "/v1/knowledge-bases/:kb/topics",
    "query": "?limit=2",
    "schema": {
      "type": "object",
      "properties": {
        "items": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "id": {
                "type": "string",
                "description": "Opaque identifier. Keep it as a string.",
                "format": "uuid"
              },
              "title": {
                "type": "string",
                "description": "Displayed piece title."
              },
              "facts": {
                "type": "string",
                "description": "Piece text."
              },
              "questions": {
                "type": "array",
                "items": {
                  "type": "string",
                  "description": ""
                },
                "description": "Retained manual/legacy labels; new imports do not generate questions."
              },
              "evidence": {
                "type": "array",
                "items": {
                  "type": "object",
                  "properties": {
                    "source": {
                      "type": "string",
                      "description": "Opaque identifier. Keep it as a string.",
                      "format": "uuid"
                    },
                    "segment": {
                      "type": "integer",
                      "description": "Source segment index."
                    },
                    "quote": {
                      "type": "string",
                      "description": "Original evidence text."
                    },
                    "quote_hash": {
                      "type": "string",
                      "description": "Digest used by a deletion record."
                    },
                    "topic_id": {
                      "type": "string",
                      "description": "Opaque identifier. Keep it as a string.",
                      "format": "uuid"
                    },
                    "revision": {
                      "type": "string",
                      "description": "Opaque identifier. Keep it as a string.",
                      "format": "uuid"
                    },
                    "title": {
                      "type": "string",
                      "description": "Title snapshot at answer time."
                    }
                  },
                  "additionalProperties": true,
                  "description": "Evidence fields vary by source, topic or answer. IDs identify supplied context, not proof that every piece affected an answer."
                },
                "description": ""
              },
              "manual": {
                "type": "boolean",
                "description": "True when manually written or corrected."
              },
              "valid_from": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "UTC timestamp.",
                "format": "date-time"
              },
              "valid_until": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "UTC timestamp.",
                "format": "date-time"
              },
              "suppressed": {
                "type": "boolean",
                "description": "True while an edited old piece must not be used."
              },
              "origin": {
                "type": "string",
                "description": "Optional legacy origin marker."
              },
              "position": {
                "type": "object",
                "properties": {
                  "added_at": {
                    "type": "string",
                    "description": "UTC timestamp.",
                    "format": "date-time"
                  },
                  "source": {
                    "type": "integer",
                    "description": ""
                  },
                  "segment": {
                    "type": "integer",
                    "description": ""
                  }
                },
                "additionalProperties": true,
                "description": "Stable display-order metadata."
              },
              "page_name": {
                "type": "string",
                "description": "Optional source page label."
              },
              "title_page": {
                "type": "string",
                "description": "Optional label used to distinguish similar automatic titles."
              },
              "review_flags": {
                "type": "array",
                "items": {
                  "type": "string",
                  "description": "",
                  "enum": [
                    "agent_instructions",
                    "suspicious_link",
                    "payment_details",
                    "sensitive_data",
                    "website_junk",
                    "code_example"
                  ]
                },
                "description": ""
              },
              "check_required": {
                "type": "boolean",
                "description": "A flagged topic needs explicit individual approval."
              },
              "check_reasons": {
                "type": "array",
                "items": {
                  "type": "string",
                  "description": "Fixed plain-language review reason."
                },
                "description": ""
              },
              "check_reason": {
                "type": "string",
                "description": "Compatibility joined review reasons."
              },
              "keyterms": {
                "type": "object",
                "properties": {
                  "version": {
                    "type": "integer",
                    "description": "Stored automatic-term format version."
                  },
                  "fingerprint": {
                    "type": "string",
                    "description": "Digest of the source text used to validate cached terms."
                  },
                  "terms": {
                    "type": "array",
                    "items": {
                      "type": "string",
                      "description": "Source-spelled automatic term."
                    },
                    "description": "Stored candidate terms."
                  },
                  "ranks": {
                    "type": "object",
                    "description": "Keys are normalized terms; each value records score (1–4) and essential (boolean).",
                    "additionalProperties": {
                      "type": "object",
                      "properties": {
                        "score": {
                          "type": "integer",
                          "description": "Stored importance.",
                          "minimum": 1,
                          "maximum": 4
                        },
                        "essential": {
                          "type": "boolean",
                          "description": "Central identity marker."
                        }
                      },
                      "required": [
                        "score",
                        "essential"
                      ],
                      "additionalProperties": true,
                      "description": ""
                    }
                  }
                },
                "additionalProperties": true,
                "description": "Read-only metadata. Refresh scheduling is still being checked separately; do not send it in writes."
              }
            },
            "required": [
              "id",
              "title",
              "facts",
              "questions",
              "evidence",
              "manual",
              "valid_from",
              "valid_until"
            ],
            "additionalProperties": true,
            "description": ""
          },
          "description": ""
        },
        "next_cursor": {
          "type": [
            "string",
            "null"
          ],
          "description": "Opaque cursor. Send it unchanged for the next page; null ends this list."
        }
      },
      "required": [
        "items",
        "next_cursor"
      ],
      "additionalProperties": true,
      "description": ""
    }
  },
  {
    "number": 121,
    "method": "GET",
    "path": "/v1/knowledge-bases/:kb/topics/:id",
    "query": "",
    "schema": {
      "type": "object",
      "properties": {
        "id": {
          "type": "string",
          "description": "Opaque identifier. Keep it as a string.",
          "format": "uuid"
        },
        "title": {
          "type": "string",
          "description": "Displayed piece title."
        },
        "facts": {
          "type": "string",
          "description": "Piece text."
        },
        "questions": {
          "type": "array",
          "items": {
            "type": "string",
            "description": ""
          },
          "description": "Retained manual/legacy labels; new imports do not generate questions."
        },
        "evidence": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "source": {
                "type": "string",
                "description": "Opaque identifier. Keep it as a string.",
                "format": "uuid"
              },
              "segment": {
                "type": "integer",
                "description": "Source segment index."
              },
              "quote": {
                "type": "string",
                "description": "Original evidence text."
              },
              "quote_hash": {
                "type": "string",
                "description": "Digest used by a deletion record."
              },
              "topic_id": {
                "type": "string",
                "description": "Opaque identifier. Keep it as a string.",
                "format": "uuid"
              },
              "revision": {
                "type": "string",
                "description": "Opaque identifier. Keep it as a string.",
                "format": "uuid"
              },
              "title": {
                "type": "string",
                "description": "Title snapshot at answer time."
              }
            },
            "additionalProperties": true,
            "description": "Evidence fields vary by source, topic or answer. IDs identify supplied context, not proof that every piece affected an answer."
          },
          "description": ""
        },
        "manual": {
          "type": "boolean",
          "description": "True when manually written or corrected."
        },
        "valid_from": {
          "type": [
            "string",
            "null"
          ],
          "description": "UTC timestamp.",
          "format": "date-time"
        },
        "valid_until": {
          "type": [
            "string",
            "null"
          ],
          "description": "UTC timestamp.",
          "format": "date-time"
        },
        "suppressed": {
          "type": "boolean",
          "description": "True while an edited old piece must not be used."
        },
        "origin": {
          "type": "string",
          "description": "Optional legacy origin marker."
        },
        "position": {
          "type": "object",
          "properties": {
            "added_at": {
              "type": "string",
              "description": "UTC timestamp.",
              "format": "date-time"
            },
            "source": {
              "type": "integer",
              "description": ""
            },
            "segment": {
              "type": "integer",
              "description": ""
            }
          },
          "additionalProperties": true,
          "description": "Stable display-order metadata."
        },
        "page_name": {
          "type": "string",
          "description": "Optional source page label."
        },
        "title_page": {
          "type": "string",
          "description": "Optional label used to distinguish similar automatic titles."
        },
        "review_flags": {
          "type": "array",
          "items": {
            "type": "string",
            "description": "",
            "enum": [
              "agent_instructions",
              "suspicious_link",
              "payment_details",
              "sensitive_data",
              "website_junk",
              "code_example"
            ]
          },
          "description": ""
        },
        "check_required": {
          "type": "boolean",
          "description": "A flagged topic needs explicit individual approval."
        },
        "check_reasons": {
          "type": "array",
          "items": {
            "type": "string",
            "description": "Fixed plain-language review reason."
          },
          "description": ""
        },
        "check_reason": {
          "type": "string",
          "description": "Compatibility joined review reasons."
        },
        "keyterms": {
          "type": "object",
          "properties": {
            "version": {
              "type": "integer",
              "description": "Stored automatic-term format version."
            },
            "fingerprint": {
              "type": "string",
              "description": "Digest of the source text used to validate cached terms."
            },
            "terms": {
              "type": "array",
              "items": {
                "type": "string",
                "description": "Source-spelled automatic term."
              },
              "description": "Stored candidate terms."
            },
            "ranks": {
              "type": "object",
              "description": "Keys are normalized terms; each value records score (1–4) and essential (boolean).",
              "additionalProperties": {
                "type": "object",
                "properties": {
                  "score": {
                    "type": "integer",
                    "description": "Stored importance.",
                    "minimum": 1,
                    "maximum": 4
                  },
                  "essential": {
                    "type": "boolean",
                    "description": "Central identity marker."
                  }
                },
                "required": [
                  "score",
                  "essential"
                ],
                "additionalProperties": true,
                "description": ""
              }
            }
          },
          "additionalProperties": true,
          "description": "Read-only metadata. Refresh scheduling is still being checked separately; do not send it in writes."
        }
      },
      "required": [
        "id",
        "title",
        "facts",
        "questions",
        "evidence",
        "manual",
        "valid_from",
        "valid_until"
      ],
      "additionalProperties": true,
      "description": ""
    }
  },
  {
    "number": 123,
    "method": "GET",
    "path": "/v1/knowledge-bases/:kb/unanswered",
    "query": "?limit=2",
    "schema": {
      "type": "object",
      "properties": {
        "items": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "id": {
                "type": "string",
                "description": "Opaque identifier. Keep it as a string.",
                "format": "uuid"
              },
              "question": {
                "type": "string",
                "description": "Private question, truncated to 4,000 characters.",
                "maxLength": 4000
              },
              "channel": {
                "type": "string",
                "description": "",
                "enum": [
                  "inbound",
                  "outbound",
                  "web_voice",
                  "web_chat",
                  "sms"
                ]
              },
              "created_at": {
                "type": "string",
                "description": "UTC timestamp.",
                "format": "date-time"
              }
            },
            "required": [
              "id",
              "question",
              "channel",
              "created_at"
            ],
            "additionalProperties": true,
            "description": ""
          },
          "description": ""
        },
        "next_cursor": {
          "type": [
            "string",
            "null"
          ],
          "description": "Opaque cursor. Send it unchanged for the next page; null ends this list."
        }
      },
      "required": [
        "items",
        "next_cursor"
      ],
      "additionalProperties": true,
      "description": ""
    }
  },
  {
    "number": 126,
    "method": "GET",
    "path": "/v1/knowledge/capabilities",
    "query": "",
    "schema": {
      "type": "object",
      "properties": {
        "released": {
          "type": "boolean",
          "description": "Current rollout marker; false is not a route failure."
        },
        "limits": {
          "type": "object",
          "properties": {
            "fileBytes": {
              "type": "integer",
              "description": "Maximum raw upload bytes: 10 MiB.",
              "example": 10485760
            },
            "pages": {
              "type": "integer",
              "description": "Maximum PDF pages.",
              "example": 200
            },
            "sourceTokens": {
              "type": "integer",
              "description": "Maximum tokens per source.",
              "example": 20000
            },
            "kbTokens": {
              "type": "integer",
              "description": "Maximum original-text tokens per base, including additional manual text.",
              "example": 100000
            },
            "sources": {
              "type": "integer",
              "description": "Maximum sources per base.",
              "example": 50
            },
            "topics": {
              "type": "integer",
              "description": "Maximum topics per base.",
              "example": 1000
            },
            "bases": {
              "type": "integer",
              "description": "Maximum active agent bases per account.",
              "example": 20
            },
            "accountBytes": {
              "type": "integer",
              "description": "Private account storage cap, 100 MiB.",
              "example": 104857600
            },
            "topicTokens": {
              "type": "integer",
              "description": "Maximum packed tokens per published piece.",
              "example": 800
            },
            "packTokens": {
              "type": "integer",
              "description": "Current runtime knowledge-pack budget; use the returned value.",
              "example": 800
            },
            "mainPromptTokens": {
              "type": "integer",
              "description": "Main prompt token limit with knowledge enabled.",
              "example": 3000
            },
            "sessionMs": {
              "type": "integer",
              "description": "Legacy five-minute value; knowledge Test has no training wait or timer gate.",
              "example": 300000
            },
            "kbDaily": {
              "type": "integer",
              "description": "Legacy per-base training counter; training is removed.",
              "example": 3
            },
            "accountDaily": {
              "type": "integer",
              "description": "Legacy account training counter; training is removed.",
              "example": 30
            },
            "notes": {
              "type": "integer",
              "description": "Legacy note limit; note routes are removed.",
              "example": 20
            },
            "noteChars": {
              "type": "integer",
              "description": "Legacy note size; note routes are removed.",
              "example": 2000
            },
            "messageChars": {
              "type": "integer",
              "description": "Maximum question characters.",
              "example": 4000
            },
            "messages": {
              "type": "integer",
              "description": "Latest retained conversation messages.",
              "example": 100
            },
            "jobs": {
              "type": "integer",
              "description": "Maximum pending/running/review jobs per account.",
              "example": 8
            },
            "parseMs": {
              "type": "integer",
              "description": "Bounded file-reader timeout, milliseconds.",
              "example": 15000
            },
            "discoveryPages": {
              "type": "integer",
              "description": "Maximum discovered website pages.",
              "example": 200
            },
            "leaseMs": {
              "type": "integer",
              "description": "Worker lease duration, milliseconds; not a client timeout.",
              "example": 240000
            },
            "attempts": {
              "type": "integer",
              "description": "Maximum processing attempts per job.",
              "example": 3
            },
            "retainedDays": {
              "type": "integer",
              "description": "Retention for transient jobs, drafts, sessions and unanswered observations.",
              "example": 7
            }
          },
          "additionalProperties": true,
          "description": ""
        },
        "defaults": {
          "type": "object",
          "properties": {
            "channels": {
              "type": "array",
              "items": {
                "type": "string",
                "description": "Channel identifier.",
                "enum": [
                  "inbound",
                  "outbound",
                  "web_voice",
                  "web_chat",
                  "sms"
                ]
              },
              "description": "Enabled knowledge channels. An empty list turns knowledge off for all channels.",
              "uniqueItems": true,
              "default": [
                "inbound"
              ]
            },
            "match": {
              "type": "string",
              "description": "Answer matching mode.",
              "enum": [
                "Strict",
                "Normal"
              ],
              "default": "Strict"
            },
            "not_found": {
              "type": "string",
              "description": "Nonblank response when suitable knowledge is missing.",
              "minLength": 1,
              "maxLength": 500,
              "default": "I don't have that information right now."
            }
          },
          "additionalProperties": false,
          "description": "Only channels, match and not_found may be supplied. Omitted settings retain the saved value on update."
        },
        "channels": {
          "type": "array",
          "items": {
            "type": "string",
            "description": "",
            "enum": [
              "inbound",
              "outbound",
              "web_voice",
              "web_chat",
              "sms"
            ]
          },
          "description": ""
        },
        "sources": {
          "type": "array",
          "items": {
            "type": "string",
            "description": "",
            "enum": [
              "file",
              "text",
              "website"
            ]
          },
          "description": ""
        },
        "test_questions": {
          "type": "string",
          "description": "",
          "const": "unlimited"
        },
        "training": {
          "type": "boolean",
          "description": "",
          "const": false
        },
        "preparation": {
          "type": "string",
          "description": "",
          "const": "original_words"
        },
        "scope_id": {
          "type": "string",
          "description": "Opaque account partition marker, 24 characters."
        },
        "policy_version": {
          "type": "string",
          "description": "Policy compatibility version."
        }
      },
      "required": [
        "released",
        "limits",
        "defaults",
        "channels",
        "sources",
        "test_questions",
        "training",
        "preparation",
        "scope_id",
        "policy_version"
      ],
      "additionalProperties": true,
      "description": ""
    }
  },
  {
    "number": 127,
    "method": "GET",
    "path": "/v1/knowledge/events",
    "query": "?cursor=0",
    "schema": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "sequence": {
            "type": "string",
            "description": "Decimal sequence string. Keep exact; pass the last sequence as cursor."
          },
          "id": {
            "type": "string",
            "description": "Opaque identifier. Keep it as a string.",
            "format": "uuid"
          },
          "kb": {
            "type": [
              "string",
              "null"
            ],
            "description": "Opaque identifier. Keep it as a string.",
            "format": "uuid"
          },
          "type": {
            "type": "string",
            "description": "Event name such as knowledge.updated or knowledge.job_ready."
          },
          "data": {
            "type": "object",
            "properties": {
              "revision": {
                "anyOf": [
                  {
                    "type": "integer",
                    "description": ""
                  },
                  {
                    "type": "string",
                    "description": "Opaque identifier. Keep it as a string.",
                    "format": "uuid"
                  }
                ]
              },
              "job_id": {
                "type": "string",
                "description": "Opaque identifier. Keep it as a string.",
                "format": "uuid"
              },
              "kind": {
                "type": "string",
                "description": ""
              },
              "topic_id": {
                "type": "string",
                "description": "Opaque identifier. Keep it as a string.",
                "format": "uuid"
              },
              "source_id": {
                "type": "string",
                "description": "Opaque identifier. Keep it as a string.",
                "format": "uuid"
              },
              "topic_count": {
                "type": "integer",
                "description": ""
              },
              "question": {
                "type": "string",
                "description": "Private unanswered observation text, when present."
              },
              "channel": {
                "type": "string",
                "description": ""
              },
              "found": {
                "type": "boolean",
                "description": ""
              }
            },
            "additionalProperties": true,
            "description": "Event-specific data; additional event fields can be present."
          },
          "created_at": {
            "type": "string",
            "description": "UTC timestamp.",
            "format": "date-time"
          }
        },
        "required": [
          "sequence",
          "id",
          "kb",
          "type",
          "data",
          "created_at"
        ],
        "additionalProperties": true,
        "description": ""
      },
      "description": "Up to 100 events in increasing sequence order."
    }
  },
  {
    "number": 128,
    "method": "GET",
    "path": "/v1/knowledge/exports/:id",
    "query": "?format=text",
    "schema": {
      "anyOf": [
        {
          "type": "object",
          "properties": {
            "format": {
              "type": "string",
              "description": "",
              "const": "nixflex-knowledge-v1"
            },
            "kb": {
              "type": "string",
              "description": "Opaque identifier. Keep it as a string.",
              "format": "uuid"
            },
            "settings": {
              "type": "object",
              "properties": {
                "channels": {
                  "type": "array",
                  "items": {
                    "type": "string",
                    "description": "Channel identifier.",
                    "enum": [
                      "inbound",
                      "outbound",
                      "web_voice",
                      "web_chat",
                      "sms"
                    ]
                  },
                  "description": "Enabled knowledge channels. An empty list turns knowledge off for all channels.",
                  "uniqueItems": true,
                  "default": [
                    "inbound"
                  ]
                },
                "match": {
                  "type": "string",
                  "description": "Answer matching mode.",
                  "enum": [
                    "Strict",
                    "Normal"
                  ],
                  "default": "Strict"
                },
                "not_found": {
                  "type": "string",
                  "description": "Nonblank response when suitable knowledge is missing.",
                  "minLength": 1,
                  "maxLength": 500,
                  "default": "I don't have that information right now."
                }
              },
              "additionalProperties": false,
              "description": "Only channels, match and not_found may be supplied. Omitted settings retain the saved value on update."
            },
            "sources": {
              "type": "array",
              "items": {
                "type": "object",
                "properties": {
                  "id": {
                    "type": "string",
                    "description": "Opaque identifier. Keep it as a string.",
                    "format": "uuid"
                  },
                  "rev": {
                    "type": "integer",
                    "description": "Latest integer revision read from this resource; it must still match when the request runs.",
                    "minimum": 1
                  },
                  "object_id": {
                    "type": "string",
                    "description": "Opaque identifier. Keep it as a string.",
                    "format": "uuid"
                  },
                  "type": {
                    "type": "string",
                    "description": "",
                    "enum": [
                      "text",
                      "file",
                      "url"
                    ]
                  },
                  "title": {
                    "type": "string",
                    "description": ""
                  },
                  "url": {
                    "type": "string",
                    "description": ""
                  },
                  "filename": {
                    "type": "string",
                    "description": ""
                  },
                  "text": {
                    "type": "string",
                    "description": "Extracted original text, never raw uploaded file bytes."
                  },
                  "tokens": {
                    "type": "integer",
                    "description": ""
                  },
                  "parsed": {
                    "type": "boolean",
                    "description": ""
                  },
                  "added_at": {
                    "type": "string",
                    "description": "UTC timestamp.",
                    "format": "date-time"
                  },
                  "source_order": {
                    "type": "integer",
                    "description": ""
                  }
                },
                "required": [
                  "id",
                  "rev",
                  "object_id",
                  "type",
                  "title"
                ],
                "additionalProperties": true,
                "description": "Accepted/staged source metadata. Older versions may retain additional metadata."
              },
              "description": ""
            },
            "topics": {
              "type": "array",
              "items": {
                "type": "object",
                "properties": {
                  "id": {
                    "type": "string",
                    "description": "Opaque identifier. Keep it as a string.",
                    "format": "uuid"
                  },
                  "title": {
                    "type": "string",
                    "description": "Displayed piece title."
                  },
                  "facts": {
                    "type": "string",
                    "description": "Piece text."
                  },
                  "questions": {
                    "type": "array",
                    "items": {
                      "type": "string",
                      "description": ""
                    },
                    "description": "Retained manual/legacy labels; new imports do not generate questions."
                  },
                  "evidence": {
                    "type": "array",
                    "items": {
                      "type": "object",
                      "properties": {
                        "source": {
                          "type": "string",
                          "description": "Opaque identifier. Keep it as a string.",
                          "format": "uuid"
                        },
                        "segment": {
                          "type": "integer",
                          "description": "Source segment index."
                        },
                        "quote": {
                          "type": "string",
                          "description": "Original evidence text."
                        },
                        "quote_hash": {
                          "type": "string",
                          "description": "Digest used by a deletion record."
                        },
                        "topic_id": {
                          "type": "string",
                          "description": "Opaque identifier. Keep it as a string.",
                          "format": "uuid"
                        },
                        "revision": {
                          "type": "string",
                          "description": "Opaque identifier. Keep it as a string.",
                          "format": "uuid"
                        },
                        "title": {
                          "type": "string",
                          "description": "Title snapshot at answer time."
                        }
                      },
                      "additionalProperties": true,
                      "description": "Evidence fields vary by source, topic or answer. IDs identify supplied context, not proof that every piece affected an answer."
                    },
                    "description": ""
                  },
                  "manual": {
                    "type": "boolean",
                    "description": "True when manually written or corrected."
                  },
                  "valid_from": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "description": "UTC timestamp.",
                    "format": "date-time"
                  },
                  "valid_until": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "description": "UTC timestamp.",
                    "format": "date-time"
                  },
                  "suppressed": {
                    "type": "boolean",
                    "description": "True while an edited old piece must not be used."
                  },
                  "origin": {
                    "type": "string",
                    "description": "Optional legacy origin marker."
                  },
                  "position": {
                    "type": "object",
                    "properties": {
                      "added_at": {
                        "type": "string",
                        "description": "UTC timestamp.",
                        "format": "date-time"
                      },
                      "source": {
                        "type": "integer",
                        "description": ""
                      },
                      "segment": {
                        "type": "integer",
                        "description": ""
                      }
                    },
                    "additionalProperties": true,
                    "description": "Stable display-order metadata."
                  },
                  "page_name": {
                    "type": "string",
                    "description": "Optional source page label."
                  },
                  "title_page": {
                    "type": "string",
                    "description": "Optional label used to distinguish similar automatic titles."
                  },
                  "review_flags": {
                    "type": "array",
                    "items": {
                      "type": "string",
                      "description": "",
                      "enum": [
                        "agent_instructions",
                        "suspicious_link",
                        "payment_details",
                        "sensitive_data",
                        "website_junk",
                        "code_example"
                      ]
                    },
                    "description": ""
                  },
                  "check_required": {
                    "type": "boolean",
                    "description": "A flagged topic needs explicit individual approval."
                  },
                  "check_reasons": {
                    "type": "array",
                    "items": {
                      "type": "string",
                      "description": "Fixed plain-language review reason."
                    },
                    "description": ""
                  },
                  "check_reason": {
                    "type": "string",
                    "description": "Compatibility joined review reasons."
                  },
                  "keyterms": {
                    "type": "object",
                    "properties": {
                      "version": {
                        "type": "integer",
                        "description": "Stored automatic-term format version."
                      },
                      "fingerprint": {
                        "type": "string",
                        "description": "Digest of the source text used to validate cached terms."
                      },
                      "terms": {
                        "type": "array",
                        "items": {
                          "type": "string",
                          "description": "Source-spelled automatic term."
                        },
                        "description": "Stored candidate terms."
                      },
                      "ranks": {
                        "type": "object",
                        "description": "Keys are normalized terms; each value records score (1–4) and essential (boolean).",
                        "additionalProperties": {
                          "type": "object",
                          "properties": {
                            "score": {
                              "type": "integer",
                              "description": "Stored importance.",
                              "minimum": 1,
                              "maximum": 4
                            },
                            "essential": {
                              "type": "boolean",
                              "description": "Central identity marker."
                            }
                          },
                          "required": [
                            "score",
                            "essential"
                          ],
                          "additionalProperties": true,
                          "description": ""
                        }
                      }
                    },
                    "additionalProperties": true,
                    "description": "Read-only metadata. Refresh scheduling is still being checked separately; do not send it in writes."
                  }
                },
                "required": [
                  "id",
                  "title",
                  "facts",
                  "questions",
                  "evidence",
                  "manual",
                  "valid_from",
                  "valid_until"
                ],
                "additionalProperties": true,
                "description": ""
              },
              "description": ""
            },
            "tombstones": {
              "type": "array",
              "items": {
                "type": "object",
                "properties": {
                  "id": {
                    "type": "string",
                    "description": "Opaque identifier. Keep it as a string.",
                    "format": "uuid"
                  },
                  "subject_hash": {
                    "type": "string",
                    "description": "Normalized title digest."
                  },
                  "evidence": {
                    "type": "array",
                    "items": {
                      "type": "object",
                      "properties": {
                        "source": {
                          "type": "string",
                          "description": "Opaque identifier. Keep it as a string.",
                          "format": "uuid"
                        },
                        "segment": {
                          "type": "integer",
                          "description": "Source segment index."
                        },
                        "quote": {
                          "type": "string",
                          "description": "Original evidence text."
                        },
                        "quote_hash": {
                          "type": "string",
                          "description": "Digest used by a deletion record."
                        },
                        "topic_id": {
                          "type": "string",
                          "description": "Opaque identifier. Keep it as a string.",
                          "format": "uuid"
                        },
                        "revision": {
                          "type": "string",
                          "description": "Opaque identifier. Keep it as a string.",
                          "format": "uuid"
                        },
                        "title": {
                          "type": "string",
                          "description": "Title snapshot at answer time."
                        }
                      },
                      "additionalProperties": true,
                      "description": "Evidence fields vary by source, topic or answer. IDs identify supplied context, not proof that every piece affected an answer."
                    },
                    "description": ""
                  }
                },
                "required": [
                  "id",
                  "subject_hash",
                  "evidence"
                ],
                "additionalProperties": true,
                "description": ""
              },
              "description": ""
            },
            "objects": {
              "type": "array",
              "items": {
                "type": "object",
                "properties": {
                  "id": {
                    "type": "string",
                    "description": "Opaque identifier. Keep it as a string.",
                    "format": "uuid"
                  },
                  "media": {
                    "type": "string",
                    "description": "",
                    "const": "text/plain"
                  },
                  "digest": {
                    "type": "string",
                    "description": "Content digest."
                  },
                  "base64": {
                    "type": "string",
                    "description": "Accepted extracted-text bytes encoded as base64, not uploaded raw-file bytes."
                  }
                },
                "required": [
                  "id",
                  "media",
                  "digest",
                  "base64"
                ],
                "additionalProperties": true,
                "description": ""
              },
              "description": ""
            }
          },
          "required": [
            "format",
            "kb",
            "settings",
            "sources",
            "topics",
            "tombstones",
            "objects"
          ],
          "additionalProperties": true,
          "description": ""
        },
        {
          "type": "object",
          "properties": {
            "filename": {
              "type": "string",
              "description": "",
              "example": "knowledge.txt"
            },
            "content_type": {
              "type": "string",
              "description": "",
              "example": "text/plain; charset=utf-8"
            },
            "text": {
              "type": "string",
              "description": "All unsuppressed live piece titles/text and plain settings."
            }
          },
          "required": [
            "filename",
            "content_type",
            "text"
          ],
          "additionalProperties": true,
          "description": ""
        }
      ]
    }
  },
  {
    "number": 129,
    "method": "GET",
    "path": "/v1/knowledge/jobs/:id",
    "query": "",
    "schema": {
      "type": "object",
      "properties": {
        "id": {
          "type": "string",
          "description": "Opaque identifier. Keep it as a string.",
          "format": "uuid"
        },
        "kb": {
          "type": "string",
          "description": "Opaque identifier. Keep it as a string.",
          "format": "uuid"
        },
        "kind": {
          "type": "string",
          "description": "Work type; includes import, discovery, publish, manual, export, delete and automatic-term maintenance."
        },
        "state": {
          "type": "string",
          "description": "",
          "enum": [
            "pending",
            "running",
            "needs_review",
            "ready",
            "failed",
            "cancelled",
            "deleted"
          ]
        },
        "stage": {
          "type": "string",
          "description": "Current work stage, including reading, preparing, indexing, safety_check or safety_waiting."
        },
        "progress": {
          "type": "object",
          "properties": {
            "percent": {
              "type": "integer",
              "description": "Completed-stage progress, not elapsed-time prediction.",
              "minimum": 0,
              "maximum": 100
            },
            "phase": {
              "type": "string",
              "description": "Reading or naming phase."
            },
            "page": {
              "type": "integer",
              "description": "Current page number."
            },
            "pages": {
              "type": "integer",
              "description": "Total input pages or entries."
            },
            "completed": {
              "type": "integer",
              "description": "Completed preparation units."
            },
            "total": {
              "type": "integer",
              "description": "Total preparation units."
            }
          },
          "required": [
            "percent"
          ],
          "additionalProperties": true,
          "description": ""
        },
        "result": {
          "type": [
            "object",
            "null"
          ],
          "properties": {
            "draft_id": {
              "type": "string",
              "description": "Opaque identifier. Keep it as a string.",
              "format": "uuid"
            },
            "warnings": {
              "type": "array",
              "items": {
                "type": "string",
                "description": ""
              },
              "description": ""
            },
            "summary": {
              "type": "object",
              "properties": {
                "pages": {
                  "type": "integer",
                  "description": "Website pages processed."
                },
                "pieces": {
                  "type": "integer",
                  "description": "Prepared pieces."
                },
                "duplicates_skipped": {
                  "type": "integer",
                  "description": "Duplicate pieces or repeated source skipped."
                }
              },
              "additionalProperties": true,
              "description": ""
            },
            "unchanged": {
              "type": "boolean",
              "description": "No new publishable content was produced."
            },
            "revision": {
              "anyOf": [
                {
                  "type": "string",
                  "description": "Opaque identifier. Keep it as a string.",
                  "format": "uuid"
                },
                {
                  "type": "integer",
                  "description": "Integer revision for an export snapshot."
                }
              ]
            },
            "expected_revision": {
              "type": "integer",
              "description": "Latest integer revision read from this resource; it must still match when the request runs.",
              "minimum": 1
            },
            "expires_at": {
              "type": "string",
              "description": "UTC timestamp.",
              "format": "date-time"
            },
            "deleted": {
              "type": "boolean",
              "description": ""
            },
            "private_objects_remaining": {
              "type": "integer",
              "description": ""
            },
            "pages": {
              "type": "array",
              "items": {
                "type": "object",
                "properties": {
                  "id": {
                    "type": "string",
                    "description": "Discovery page ID, use exactly as returned."
                  },
                  "url": {
                    "type": "string",
                    "description": "Discovered public page URL."
                  },
                  "title": {
                    "type": "string",
                    "description": "Discovered page title."
                  }
                },
                "required": [
                  "id",
                  "url"
                ],
                "additionalProperties": true,
                "description": ""
              },
              "description": ""
            }
          },
          "additionalProperties": true,
          "description": "Fields depend on job kind. Poll the job until a terminal state or needs_review; ready alone is not a claim that new text was published."
        },
        "error": {
          "type": [
            "object",
            "null"
          ],
          "properties": {
            "code": {
              "type": "string",
              "description": "Machine-readable failure code; see the error catalog."
            },
            "message": {
              "type": "string",
              "description": "Display as escaped text; never execute or insert as HTML."
            }
          },
          "required": [
            "code",
            "message"
          ],
          "additionalProperties": true,
          "description": ""
        },
        "next_retry_at": {
          "type": [
            "string",
            "null"
          ],
          "description": "UTC timestamp.",
          "format": "date-time"
        },
        "paid_work_started": {
          "type": "boolean",
          "description": "Whether paid preparation work began; not an invoice or an additional charge."
        },
        "created_at": {
          "type": "string",
          "description": "UTC timestamp.",
          "format": "date-time"
        }
      },
      "required": [
        "id",
        "kb",
        "kind",
        "state",
        "stage",
        "progress",
        "result",
        "error",
        "next_retry_at",
        "paid_work_started",
        "created_at"
      ],
      "additionalProperties": true,
      "description": ""
    }
  },
  {
    "number": 132,
    "method": "GET",
    "path": "/v1/knowledge/targets",
    "query": "?limit=2",
    "schema": {
      "type": "object",
      "properties": {
        "items": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "id": {
                "type": "string",
                "description": "Agent ID."
              },
              "kind": {
                "type": "string",
                "description": "",
                "const": "agent"
              },
              "name": {
                "type": "string",
                "description": ""
              },
              "editorId": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Dashboard record identifier."
              },
              "voice_id": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Legacy voice alias."
              },
              "topic_count": {
                "type": "integer",
                "description": ""
              },
              "live": {
                "type": "boolean",
                "description": "An active published revision exists."
              },
              "has_knowledge": {
                "type": "boolean",
                "description": "A ready knowledge base exists."
              }
            },
            "required": [
              "id",
              "kind",
              "name",
              "editorId",
              "voice_id",
              "topic_count",
              "live",
              "has_knowledge"
            ],
            "additionalProperties": true,
            "description": ""
          },
          "description": ""
        },
        "next_cursor": {
          "type": [
            "string",
            "null"
          ],
          "description": "Opaque cursor. Send it unchanged for the next page; null ends this list."
        }
      },
      "required": [
        "items",
        "next_cursor"
      ],
      "additionalProperties": true,
      "description": ""
    }
  },
  {
    "number": 133,
    "method": "GET",
    "path": "/v1/knowledge/test-sessions/:id",
    "query": "",
    "schema": {
      "type": "object",
      "properties": {
        "id": {
          "type": "string",
          "description": "Opaque identifier. Keep it as a string.",
          "format": "uuid"
        },
        "owner": {
          "type": "string",
          "description": "Owning account ID."
        },
        "kb": {
          "type": "string",
          "description": "Opaque identifier. Keep it as a string.",
          "format": "uuid"
        },
        "expected_rev": {
          "type": "integer",
          "description": "Latest integer revision read from this resource; it must still match when the request runs.",
          "minimum": 1
        },
        "started_at": {
          "type": "string",
          "description": "UTC timestamp.",
          "format": "date-time"
        },
        "data": {
          "type": "object",
          "properties": {
            "mode": {
              "type": "string",
              "description": "",
              "const": "knowledge"
            },
            "channel": {
              "type": "string",
              "description": "",
              "enum": [
                "inbound",
                "outbound",
                "web_voice",
                "web_chat",
                "sms"
              ]
            },
            "draft_id": {
              "type": [
                "string",
                "null"
              ],
              "description": "Opaque identifier. Keep it as a string.",
              "format": "uuid"
            },
            "target": {
              "type": "object",
              "properties": {
                "kind": {
                  "type": "string",
                  "description": "",
                  "const": "agent"
                },
                "target": {
                  "type": "string",
                  "description": "Agent ID."
                }
              },
              "required": [
                "kind",
                "target"
              ],
              "additionalProperties": true,
              "description": ""
            },
            "messages": {
              "type": "array",
              "items": {
                "type": "object",
                "properties": {
                  "kb": {
                    "type": "string",
                    "description": "Opaque identifier. Keep it as a string.",
                    "format": "uuid"
                  },
                  "id": {
                    "type": "string",
                    "description": "Opaque identifier. Keep it as a string.",
                    "format": "uuid"
                  },
                  "role": {
                    "type": "string",
                    "description": "",
                    "enum": [
                      "user",
                      "assistant"
                    ]
                  },
                  "text": {
                    "type": "string",
                    "description": "Test conversation text."
                  },
                  "evidence": {
                    "type": "array",
                    "items": {
                      "type": "object",
                      "properties": {
                        "source": {
                          "type": "string",
                          "description": "Opaque identifier. Keep it as a string.",
                          "format": "uuid"
                        },
                        "segment": {
                          "type": "integer",
                          "description": "Source segment index."
                        },
                        "quote": {
                          "type": "string",
                          "description": "Original evidence text."
                        },
                        "quote_hash": {
                          "type": "string",
                          "description": "Digest used by a deletion record."
                        },
                        "topic_id": {
                          "type": "string",
                          "description": "Opaque identifier. Keep it as a string.",
                          "format": "uuid"
                        },
                        "revision": {
                          "type": "string",
                          "description": "Opaque identifier. Keep it as a string.",
                          "format": "uuid"
                        },
                        "title": {
                          "type": "string",
                          "description": "Title snapshot at answer time."
                        }
                      },
                      "additionalProperties": true,
                      "description": "Evidence fields vary by source, topic or answer. IDs identify supplied context, not proof that every piece affected an answer."
                    },
                    "description": ""
                  },
                  "selection": {
                    "type": "string",
                    "description": "",
                    "enum": [
                      "whole_base",
                      "search"
                    ]
                  },
                  "preview": {
                    "type": "boolean",
                    "description": ""
                  },
                  "simulated": {
                    "type": "boolean",
                    "description": "No call, text, booking or integration action runs."
                  },
                  "diagnostics": {
                    "type": "object",
                    "properties": {
                      "mode": {
                        "type": "string",
                        "description": ""
                      },
                      "method": {
                        "type": [
                          "string",
                          "null"
                        ],
                        "description": ""
                      },
                      "best_score": {
                        "type": [
                          "number",
                          "null"
                        ]
                      },
                      "reason": {
                        "type": "string",
                        "description": ""
                      }
                    },
                    "additionalProperties": true,
                    "description": "API diagnostics only; these scores are not answer-correctness measurements."
                  }
                },
                "required": [
                  "id",
                  "role",
                  "text"
                ],
                "additionalProperties": true,
                "description": ""
              },
              "description": "Latest 100 messages; questions are unlimited.",
              "maxItems": 100
            },
            "state": {
              "type": "string",
              "description": "",
              "enum": [
                "active",
                "cancelled",
                "closed"
              ]
            },
            "pending_message": {
              "type": [
                "string",
                "null"
              ],
              "description": "Opaque identifier. Keep it as a string.",
              "format": "uuid"
            }
          },
          "required": [
            "mode",
            "channel",
            "draft_id",
            "target",
            "messages",
            "state"
          ],
          "additionalProperties": true,
          "description": ""
        }
      },
      "required": [
        "id",
        "owner",
        "kb",
        "expected_rev",
        "started_at",
        "data"
      ],
      "additionalProperties": true,
      "description": ""
    }
  },
  {
    "number": 136,
    "method": "GET",
    "path": "/v1/knowledge/usage",
    "query": "",
    "schema": {
      "type": "object",
      "properties": {
        "quota": {
          "type": "object",
          "properties": {
            "remaining_today": {
              "type": "integer",
              "description": "Legacy per-base training units."
            },
            "account_remaining": {
              "type": "integer",
              "description": "Legacy account training units."
            },
            "resets_at": {
              "type": "string",
              "description": "UTC timestamp.",
              "format": "date-time"
            },
            "starts_at": {
              "type": "string",
              "description": "UTC timestamp.",
              "format": "date-time"
            },
            "timezone": {
              "type": "string",
              "description": "Account reset timezone."
            }
          },
          "required": [
            "remaining_today",
            "account_remaining",
            "resets_at",
            "starts_at",
            "timezone"
          ],
          "additionalProperties": true,
          "description": ""
        },
        "inventory": {
          "type": "object",
          "properties": {
            "bases": {
              "type": "object",
              "properties": {
                "count": {
                  "type": "integer",
                  "description": "Owned row count."
                }
              },
              "required": [
                "count"
              ],
              "additionalProperties": true,
              "description": ""
            },
            "policies": {
              "type": "object",
              "properties": {
                "count": {
                  "type": "integer",
                  "description": "Owned row count."
                }
              },
              "required": [
                "count"
              ],
              "additionalProperties": true,
              "description": ""
            },
            "sources": {
              "type": "object",
              "properties": {
                "count": {
                  "type": "integer",
                  "description": "Owned row count."
                }
              },
              "required": [
                "count"
              ],
              "additionalProperties": true,
              "description": ""
            },
            "objects": {
              "type": "object",
              "properties": {
                "count": {
                  "type": "integer",
                  "description": "Owned row count."
                }
              },
              "required": [
                "count"
              ],
              "additionalProperties": true,
              "description": ""
            },
            "revisions": {
              "type": "object",
              "properties": {
                "count": {
                  "type": "integer",
                  "description": "Owned row count."
                }
              },
              "required": [
                "count"
              ],
              "additionalProperties": true,
              "description": ""
            },
            "topics": {
              "type": "object",
              "properties": {
                "count": {
                  "type": "integer",
                  "description": "Owned row count."
                }
              },
              "required": [
                "count"
              ],
              "additionalProperties": true,
              "description": ""
            },
            "drafts": {
              "type": "object",
              "properties": {
                "count": {
                  "type": "integer",
                  "description": "Owned row count."
                }
              },
              "required": [
                "count"
              ],
              "additionalProperties": true,
              "description": ""
            },
            "sessions": {
              "type": "object",
              "properties": {
                "count": {
                  "type": "integer",
                  "description": "Owned row count."
                }
              },
              "required": [
                "count"
              ],
              "additionalProperties": true,
              "description": ""
            },
            "jobs": {
              "type": "object",
              "properties": {
                "count": {
                  "type": "integer",
                  "description": "Owned row count."
                }
              },
              "required": [
                "count"
              ],
              "additionalProperties": true,
              "description": ""
            },
            "idempotency": {
              "type": "object",
              "properties": {
                "count": {
                  "type": "integer",
                  "description": "Owned row count."
                }
              },
              "required": [
                "count"
              ],
              "additionalProperties": true,
              "description": ""
            },
            "events": {
              "type": "object",
              "properties": {
                "count": {
                  "type": "integer",
                  "description": "Owned row count."
                }
              },
              "required": [
                "count"
              ],
              "additionalProperties": true,
              "description": ""
            },
            "accounts": {
              "type": "object",
              "properties": {
                "count": {
                  "type": "integer",
                  "description": "Owned row count."
                }
              },
              "required": [
                "count"
              ],
              "additionalProperties": true,
              "description": ""
            }
          },
          "additionalProperties": true,
          "description": ""
        },
        "billing": {
          "type": "string",
          "description": "Compatibility billing text; not a new charge."
        }
      },
      "required": [
        "quota",
        "inventory",
        "billing"
      ],
      "additionalProperties": true,
      "description": ""
    }
  },
  {
    "number": 143,
    "method": "GET",
    "path": "/v1/organisation",
    "query": "",
    "schema": {
      "type": "object",
      "properties": {
        "organisation_id": {
          "type": "string",
          "description": "UUID identifier.",
          "format": "uuid"
        },
        "key_id": {
          "type": "string",
          "description": "Account key ID, not the secret."
        },
        "name": {
          "type": "string",
          "description": "Business name."
        },
        "role": {
          "type": "string",
          "description": "Current personal role. API-key authority is owner.",
          "enum": [
            "owner",
            "admin",
            "member"
          ]
        },
        "user_id": {
          "type": [
            "string",
            "null"
          ],
          "description": "UUID identifier.",
          "format": "uuid"
        },
        "membership_version": {
          "type": [
            "integer",
            "null"
          ],
          "description": "Personal membership version; null for an API key."
        },
        "joined_at": {
          "type": [
            "string",
            "null"
          ],
          "description": "UTC timestamp.",
          "format": "date-time"
        },
        "is_active": {
          "type": "boolean",
          "description": "The account is active.",
          "const": true
        },
        "dashboard_state": {
          "type": "string",
          "description": "Active account state.",
          "const": "active"
        },
        "permissions": {
          "type": "array",
          "items": {
            "type": "string",
            "description": "Role permission name."
          },
          "description": ""
        }
      },
      "required": [
        "organisation_id",
        "key_id",
        "name",
        "role",
        "user_id",
        "membership_version",
        "joined_at",
        "is_active",
        "dashboard_state",
        "permissions"
      ],
      "additionalProperties": false,
      "description": ""
    }
  },
  {
    "number": 145,
    "method": "GET",
    "path": "/v1/organisation/activity",
    "query": "",
    "schema": {
      "type": "object",
      "properties": {
        "events": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "id": {
                "type": "string",
                "description": "Decimal event ID. Treat as an opaque string."
              },
              "created_at": {
                "type": "string",
                "description": "UTC timestamp.",
                "format": "date-time"
              },
              "actor_id": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "UUID identifier.",
                "format": "uuid"
              },
              "actor": {
                "type": "string",
                "description": "Human-readable actor label."
              },
              "sentence": {
                "type": "string",
                "description": "Human-readable action sentence."
              },
              "result": {
                "type": "string",
                "description": "Displayed outcome.",
                "enum": [
                  "Done",
                  "Not allowed",
                  "Not confirmed"
                ]
              }
            },
            "required": [
              "id",
              "created_at",
              "actor_id",
              "actor",
              "sentence",
              "result"
            ],
            "additionalProperties": false,
            "description": ""
          },
          "description": "Up to 50 events.",
          "maxItems": 50
        },
        "next_cursor": {
          "type": [
            "string",
            "null"
          ],
          "description": "Pass as before on the next JSON request; null when no full page remains."
        }
      },
      "required": [
        "events",
        "next_cursor"
      ],
      "additionalProperties": false,
      "description": ""
    }
  },
  {
    "number": 152,
    "method": "GET",
    "path": "/v1/organisation/members",
    "query": "",
    "schema": {
      "type": "object",
      "properties": {
        "members": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "user_id": {
                "type": "string",
                "description": "UUID identifier.",
                "format": "uuid"
              },
              "email": {
                "type": "string",
                "description": "Member email."
              },
              "name": {
                "type": "string",
                "description": "Display name; may be empty."
              },
              "role": {
                "type": "string",
                "description": "Current personal role. API-key authority is owner.",
                "enum": [
                  "owner",
                  "admin",
                  "member"
                ]
              },
              "joined_at": {
                "type": "string",
                "description": "UTC timestamp.",
                "format": "date-time"
              },
              "last_active_at": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "UTC timestamp.",
                "format": "date-time"
              }
            },
            "required": [
              "user_id",
              "email",
              "name",
              "role",
              "joined_at",
              "last_active_at"
            ],
            "additionalProperties": false,
            "description": ""
          },
          "description": "Active members, ordered by join time."
        },
        "invites": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "id": {
                "type": "string",
                "description": "UUID identifier.",
                "format": "uuid"
              },
              "email": {
                "type": "string",
                "description": "Invited email."
              },
              "role": {
                "type": "string",
                "description": "Current personal role. API-key authority is owner.",
                "enum": [
                  "owner",
                  "admin",
                  "member"
                ]
              },
              "state": {
                "type": "string",
                "description": "Pending rows whose expiry passed are displayed as expired.",
                "enum": [
                  "pending",
                  "expired"
                ]
              },
              "delivery": {
                "type": "string",
                "description": "Delivery status.",
                "enum": [
                  "pending",
                  "sent",
                  "failed",
                  "unknown"
                ]
              },
              "expires_at": {
                "type": "string",
                "description": "UTC timestamp.",
                "format": "date-time"
              }
            },
            "required": [
              "id",
              "email",
              "role",
              "state",
              "delivery",
              "expires_at"
            ],
            "additionalProperties": false,
            "description": ""
          },
          "description": "Up to 100 rows, newest first; no cursor.",
          "maxItems": 100
        },
        "limits": {
          "type": "object",
          "properties": {
            "members": {
              "type": "integer",
              "description": "Maximum active members plus unexpired pending invitations."
            },
            "invites_per_day": {
              "type": "integer",
              "description": "Daily invitation limit."
            },
            "invites_used_today": {
              "type": "integer",
              "description": "Invitations used today in UTC."
            },
            "seats_used": {
              "type": "integer",
              "description": "Active members plus unexpired pending invitations."
            }
          },
          "required": [
            "members",
            "invites_per_day",
            "invites_used_today",
            "seats_used"
          ],
          "additionalProperties": false,
          "description": ""
        }
      },
      "required": [
        "members",
        "invites",
        "limits"
      ],
      "additionalProperties": false,
      "description": ""
    }
  },
  {
    "number": 164,
    "method": "GET",
    "path": "/v1/phone-numbers",
    "query": "?limit=100",
    "schema": {
      "type": "object",
      "required": [
        "phone_numbers",
        "count"
      ],
      "properties": {
        "phone_numbers": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "source": {
                "type": [
                  "string",
                  "null"
                ],
                "enum": [
                  "api",
                  "dashboard",
                  null
                ],
                "readOnly": true,
                "description": "Descriptive origin, never a permission or writable setting."
              },
              "created_at": {
                "type": [
                  "string",
                  "null"
                ],
                "format": "date-time"
              },
              "web_agent_enabled": {
                "type": "boolean"
              },
              "web_calls_enabled": {
                "type": "boolean",
                "description": "Saved switch; website voice also needs Web agent ON."
              },
              "web_functions_enabled": {
                "type": "boolean"
              },
              "monitor_enabled": {
                "type": "boolean"
              },
              "phone_number": {
                "type": "string",
                "example": "+447446466847"
              },
              "agent_id": {
                "type": "string"
              },
              "inbound_enabled": {
                "type": "boolean"
              },
              "outbound_enabled": {
                "type": "boolean"
              },
              "custom_prompt": {
                "type": [
                  "string",
                  "null"
                ]
              },
              "voice_id": {
                "type": [
                  "string",
                  "null"
                ]
              },
              "sms_reply_enabled": {
                "type": "boolean"
              },
              "voicemail_leave_enabled": {
                "type": [
                  "boolean",
                  "null"
                ],
                "description": "This number's own voicemail setting - the ONLY one that applies to API-imported numbers. null = not set = silent hangup on voicemail."
              },
              "voicemail_message": {
                "type": [
                  "string",
                  "null"
                ]
              },
              "sms_prompt": {
                "type": [
                  "string",
                  "null"
                ]
              },
              "web_prompt": {
                "type": [
                  "string",
                  "null"
                ]
              },
              "speaking_rate": {
                "type": [
                  "number",
                  "null"
                ]
              },
              "dtmf_enabled": {
                "type": [
                  "boolean",
                  "null"
                ]
              },
              "require_booking_confirmation": {
                "type": [
                  "boolean",
                  "null"
                ],
                "description": "true / false for this number, null = inherit the agent. See /actions/booking-confirmation."
              },
              "record_call": {
                "type": [
                  "boolean",
                  "null"
                ]
              },
              "recording_source": {
                "type": [
                  "string",
                  "null"
                ],
                "enum": [
                  "provider",
                  "nixflex"
                ],
                "description": "Who records on this number. null = inherit the agent."
              }
            },
            "additionalProperties": true
          }
        },
        "count": {
          "type": "integer",
          "minimum": 0
        },
        "next_cursor": {
          "type": [
            "string",
            "null"
          ]
        },
        "has_more": {
          "type": "boolean"
        }
      }
    }
  },
  {
    "number": 167,
    "method": "GET",
    "path": "/v1/phone-numbers/:phoneNumber",
    "query": "",
    "schema": {
      "type": "object",
      "required": [
        "phone_number"
      ],
      "properties": {
        "phone_number": {
          "type": "object",
          "description": "Explicit safe saved settings. Null means unset, not a resolved agent value. No credentials or internal IDs.",
          "additionalProperties": false,
          "required": [
            "phone_number",
            "agent_id",
            "source",
            "created_at",
            "inbound_enabled",
            "outbound_enabled",
            "sms_reply_enabled",
            "web_agent_enabled",
            "web_calls_enabled",
            "web_functions_enabled",
            "monitor_enabled",
            "custom_prompt",
            "sms_prompt",
            "web_prompt",
            "voice_id",
            "speaking_rate",
            "dtmf_enabled",
            "require_booking_confirmation",
            "record_call",
            "recording_source",
            "voicemail_leave_enabled",
            "voicemail_message",
            "web_calls_effective"
          ],
          "properties": {
            "phone_number": {
              "type": "string"
            },
            "agent_id": {
              "type": [
                "string",
                "null"
              ]
            },
            "source": {
              "type": [
                "string",
                "null"
              ],
              "enum": [
                "api",
                "dashboard",
                null
              ],
              "readOnly": true,
              "description": "Descriptive only, not writable or a permission."
            },
            "created_at": {
              "type": [
                "string",
                "null"
              ],
              "format": "date-time"
            },
            "inbound_enabled": {
              "type": [
                "boolean",
                "null"
              ]
            },
            "outbound_enabled": {
              "type": [
                "boolean",
                "null"
              ]
            },
            "sms_reply_enabled": {
              "type": [
                "boolean",
                "null"
              ]
            },
            "web_agent_enabled": {
              "type": [
                "boolean",
                "null"
              ]
            },
            "web_calls_enabled": {
              "type": [
                "boolean",
                "null"
              ]
            },
            "web_functions_enabled": {
              "type": [
                "boolean",
                "null"
              ]
            },
            "monitor_enabled": {
              "type": [
                "boolean",
                "null"
              ]
            },
            "custom_prompt": {
              "type": [
                "string",
                "null"
              ]
            },
            "sms_prompt": {
              "type": [
                "string",
                "null"
              ]
            },
            "web_prompt": {
              "type": [
                "string",
                "null"
              ]
            },
            "voice_id": {
              "type": [
                "string",
                "null"
              ]
            },
            "speaking_rate": {
              "type": [
                "number",
                "null"
              ]
            },
            "dtmf_enabled": {
              "type": [
                "boolean",
                "null"
              ]
            },
            "require_booking_confirmation": {
              "type": [
                "boolean",
                "null"
              ]
            },
            "record_call": {
              "type": [
                "boolean",
                "null"
              ]
            },
            "recording_source": {
              "type": [
                "string",
                "null"
              ],
              "enum": [
                "provider",
                "nixflex",
                null
              ]
            },
            "voicemail_leave_enabled": {
              "type": [
                "boolean",
                "null"
              ]
            },
            "voicemail_message": {
              "type": [
                "string",
                "null"
              ]
            },
            "web_calls_effective": {
              "type": "boolean",
              "readOnly": true,
              "description": "Saved website voice true and Web agent not false (legacy null retains old semantics). Switch eligibility only; active/billing admission still applies."
            }
          }
        }
      }
    }
  },
  {
    "number": 170,
    "method": "GET",
    "path": "/v1/phone-numbers/:phoneNumber/callers/:callerNumber",
    "query": "",
    "schema": {
      "type": "object",
      "properties": {
        "caller": {
          "type": "object",
          "properties": {
            "phone_number": {
              "type": "string"
            },
            "caller_number": {
              "type": "string"
            },
            "context": {
              "type": "object",
              "description": "Only fields with a value are present.",
              "properties": {
                "name": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "maxLength": 120,
                  "description": "Full name - first and last."
                },
                "email": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "format": "email",
                  "maxLength": 120
                },
                "phone": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "maxLength": 40,
                  "description": "A contact number other than the one they call from."
                },
                "location": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "maxLength": 120,
                  "description": "Free text - city, area or postal code."
                },
                "reference_id": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "maxLength": 64,
                  "description": "An account, order or booking reference the caller uses."
                },
                "preference": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "maxLength": 200,
                  "example": "prefers morning appointments"
                },
                "last_call": {
                  "type": "string",
                  "readOnly": true,
                  "description": "Engine-written. What the caller wanted on their last call - never what happened."
                },
                "open_item": {
                  "type": "string",
                  "readOnly": true,
                  "description": "Engine-written. Something still pending for the caller."
                }
              }
            }
          },
          "required": [
            "phone_number",
            "caller_number",
            "context"
          ]
        }
      },
      "required": [
        "caller"
      ]
    }
  },
  {
    "number": 173,
    "method": "GET",
    "path": "/v1/phone-numbers/:phoneNumber/usage",
    "query": "?period=today",
    "schema": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "usage"
      ],
      "properties": {
        "usage": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "phone_number",
            "period",
            "time_zone",
            "period_start",
            "period_end",
            "start_inclusive",
            "end_inclusive",
            "currency",
            "duration_unit",
            "call_count",
            "total_ms",
            "minutes",
            "last_call",
            "total_cost",
            "unpriced_calls",
            "sms_sent",
            "sms_received",
            "sms_count",
            "web_chats",
            "unused",
            "history_note"
          ],
          "properties": {
            "phone_number": {
              "type": "string"
            },
            "period": {
              "type": "string",
              "enum": [
                "today",
                "7",
                "14",
                "30",
                "90",
                "all"
              ]
            },
            "time_zone": {
              "type": "string"
            },
            "period_start": {
              "type": [
                "string",
                "null"
              ],
              "format": "date-time",
              "description": "Inclusive boundary; null for all retained history."
            },
            "period_end": {
              "type": "string",
              "format": "date-time",
              "description": "Inclusive server query cutoff."
            },
            "start_inclusive": {
              "type": "boolean",
              "const": true
            },
            "end_inclusive": {
              "type": "boolean",
              "const": true
            },
            "currency": {
              "type": "string",
              "const": "USD"
            },
            "duration_unit": {
              "type": "string",
              "const": "milliseconds"
            },
            "call_count": {
              "type": "integer",
              "minimum": 0
            },
            "total_ms": {
              "type": "integer",
              "minimum": 0
            },
            "minutes": {
              "type": "number",
              "description": "total_ms / 60000, rounded to six decimals. total_ms is authoritative."
            },
            "last_call": {
              "type": [
                "string",
                "null"
              ],
              "format": "date-time"
            },
            "total_cost": {
              "type": "string",
              "pattern": "^-?[0-9]+(?:\\.[0-9]+)?$",
              "description": "Exact decimal USD sum of retained calls.cost. No repricing. Display to two decimals to match the dashboard."
            },
            "unpriced_calls": {
              "type": "integer",
              "minimum": 0,
              "description": "Retained calls where cost IS NULL, not zero."
            },
            "sms_sent": {
              "type": "integer",
              "minimum": 0
            },
            "sms_received": {
              "type": "integer",
              "minimum": 0
            },
            "sms_count": {
              "type": "integer",
              "minimum": 0
            },
            "web_chats": {
              "type": "integer",
              "minimum": 0,
              "description": "Distinct session IDs with messages in the period, bound to the current number row and owner."
            },
            "unused": {
              "type": "boolean",
              "description": "Zero calls AND zero SMS in this period; web chats do not affect this field."
            },
            "history_note": {
              "type": "string",
              "description": "Retained history, not a billing ledger; only recorded call charges, no provider SMS charges."
            }
          }
        }
      }
    }
  },
  {
    "number": 175,
    "method": "GET",
    "path": "/v1/sms/campaigns",
    "query": "?limit=2",
    "schema": {
      "type": "object",
      "properties": {
        "campaigns": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "campaign_id": {
                "type": "string",
                "description": "Public campaign ID."
              },
              "agent_id": {
                "type": "string",
                "description": "Owning agent ID."
              },
              "name": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Saved campaign label."
              },
              "from_number": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "International number with + and digits; no spaces.",
                "pattern": "^\\+[1-9][0-9]{6,14}$"
              },
              "schedule_type": {
                "type": "string",
                "description": "Saved now or schedule mode."
              },
              "scheduled_date": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Saved scheduled date."
              },
              "window_start_minutes": {
                "type": [
                  "integer",
                  "null"
                ],
                "description": "Configured start minute."
              },
              "window_end_minutes": {
                "type": [
                  "integer",
                  "null"
                ],
                "description": "Configured end minute."
              },
              "window_days": {
                "type": [
                  "array",
                  "null"
                ],
                "items": {
                  "type": "string",
                  "description": "Weekday."
                },
                "description": ""
              },
              "timezone": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Saved campaign time zone."
              },
              "source": {
                "type": "string",
                "description": "Saved origin label."
              },
              "status": {
                "type": "string",
                "description": "Current state; for example scheduled, launching, running, done, failed or cancelled. Treat new states conservatively."
              },
              "total_count": {
                "type": "integer",
                "description": "Count.",
                "minimum": 0
              },
              "started_at": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Saved timestamp, or null.",
                "format": "date-time"
              },
              "completed_at": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Saved timestamp, or null.",
                "format": "date-time"
              },
              "created_at": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Saved timestamp, or null.",
                "format": "date-time"
              },
              "updated_at": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Saved timestamp, or null.",
                "format": "date-time"
              },
              "allow_wider_hours": {
                "type": "boolean",
                "description": "True only with confirmation evidence for the current policy revision."
              },
              "id": {
                "type": "string",
                "description": "Internal row ID used in list cursors.",
                "format": "uuid"
              },
              "api_key_id": {
                "type": "string",
                "description": "Owning account ID, not its secret."
              },
              "message_template": {
                "type": "string",
                "description": "Saved text template."
              },
              "reply_context_prompt": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Saved reply instructions."
              },
              "reply_window_hours": {
                "type": "integer",
                "description": "Reply association window in hours."
              },
              "is_active": {
                "type": "boolean",
                "description": "Reply behaviour enabled flag; not a dispatch cancellation control."
              },
              "claimed_at": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Saved timestamp, or null.",
                "format": "date-time"
              },
              "sent_count": {
                "type": "integer",
                "description": "Rows accepted for sending, including delivered or replied rows. Can overlap with later failures."
              },
              "delivered_count": {
                "type": "integer",
                "description": "Delivered or replied rows."
              },
              "failed_count": {
                "type": "integer",
                "description": "Failed or undelivered rows."
              },
              "reply_count": {
                "type": "integer",
                "description": "Recipients marked replied."
              },
              "total_segments": {
                "type": "integer",
                "description": "Estimated sum of recipient segments."
              },
              "pending_count": {
                "type": "integer",
                "description": "Rows pending or queued."
              },
              "segments_estimated": {
                "type": "boolean",
                "description": "Reported segments are estimates.",
                "const": true
              }
            },
            "required": [
              "campaign_id",
              "agent_id",
              "name",
              "from_number",
              "schedule_type",
              "scheduled_date",
              "window_start_minutes",
              "window_end_minutes",
              "window_days",
              "timezone",
              "source",
              "status",
              "total_count",
              "started_at",
              "completed_at",
              "created_at",
              "updated_at",
              "allow_wider_hours",
              "id",
              "api_key_id",
              "message_template",
              "reply_context_prompt",
              "reply_window_hours",
              "is_active",
              "claimed_at",
              "sent_count",
              "delivered_count",
              "failed_count",
              "reply_count",
              "total_segments",
              "pending_count",
              "segments_estimated"
            ],
            "description": "",
            "additionalProperties": false
          },
          "description": ""
        },
        "next_cursor": {
          "type": [
            "string",
            "null"
          ],
          "description": "Opaque next page cursor. Nonempty pages produce a cursor even when shorter than the limit."
        }
      },
      "required": [
        "campaigns",
        "next_cursor"
      ],
      "description": "",
      "additionalProperties": false
    }
  },
  {
    "number": 178,
    "method": "GET",
    "path": "/v1/sms/campaigns/:id",
    "query": "?limit=2",
    "schema": {
      "type": "object",
      "properties": {
        "campaign": {
          "type": "object",
          "properties": {
            "campaign_id": {
              "type": "string",
              "description": "Public campaign ID."
            },
            "agent_id": {
              "type": "string",
              "description": "Owning agent ID."
            },
            "name": {
              "type": [
                "string",
                "null"
              ],
              "description": "Saved campaign label."
            },
            "from_number": {
              "type": [
                "string",
                "null"
              ],
              "description": "International number with + and digits; no spaces.",
              "pattern": "^\\+[1-9][0-9]{6,14}$"
            },
            "schedule_type": {
              "type": "string",
              "description": "Saved now or schedule mode."
            },
            "scheduled_date": {
              "type": [
                "string",
                "null"
              ],
              "description": "Saved scheduled date."
            },
            "window_start_minutes": {
              "type": [
                "integer",
                "null"
              ],
              "description": "Configured start minute."
            },
            "window_end_minutes": {
              "type": [
                "integer",
                "null"
              ],
              "description": "Configured end minute."
            },
            "window_days": {
              "type": [
                "array",
                "null"
              ],
              "items": {
                "type": "string",
                "description": "Weekday."
              },
              "description": ""
            },
            "timezone": {
              "type": [
                "string",
                "null"
              ],
              "description": "Saved campaign time zone."
            },
            "source": {
              "type": "string",
              "description": "Saved origin label."
            },
            "status": {
              "type": "string",
              "description": "Current state; for example scheduled, launching, running, done, failed or cancelled. Treat new states conservatively."
            },
            "total_count": {
              "type": "integer",
              "description": "Count.",
              "minimum": 0
            },
            "started_at": {
              "type": [
                "string",
                "null"
              ],
              "description": "Saved timestamp, or null.",
              "format": "date-time"
            },
            "completed_at": {
              "type": [
                "string",
                "null"
              ],
              "description": "Saved timestamp, or null.",
              "format": "date-time"
            },
            "created_at": {
              "type": [
                "string",
                "null"
              ],
              "description": "Saved timestamp, or null.",
              "format": "date-time"
            },
            "updated_at": {
              "type": [
                "string",
                "null"
              ],
              "description": "Saved timestamp, or null.",
              "format": "date-time"
            },
            "allow_wider_hours": {
              "type": "boolean",
              "description": "True only with confirmation evidence for the current policy revision."
            },
            "id": {
              "type": "string",
              "description": "Internal row ID used in list cursors.",
              "format": "uuid"
            },
            "api_key_id": {
              "type": "string",
              "description": "Owning account ID, not its secret."
            },
            "message_template": {
              "type": "string",
              "description": "Saved text template."
            },
            "reply_context_prompt": {
              "type": [
                "string",
                "null"
              ],
              "description": "Saved reply instructions."
            },
            "reply_window_hours": {
              "type": "integer",
              "description": "Reply association window in hours."
            },
            "is_active": {
              "type": "boolean",
              "description": "Reply behaviour enabled flag; not a dispatch cancellation control."
            },
            "claimed_at": {
              "type": [
                "string",
                "null"
              ],
              "description": "Saved timestamp, or null.",
              "format": "date-time"
            },
            "sent_count": {
              "type": "integer",
              "description": "Rows accepted for sending, including delivered or replied rows. Can overlap with later failures."
            },
            "delivered_count": {
              "type": "integer",
              "description": "Delivered or replied rows."
            },
            "failed_count": {
              "type": "integer",
              "description": "Failed or undelivered rows."
            },
            "reply_count": {
              "type": "integer",
              "description": "Recipients marked replied."
            },
            "total_segments": {
              "type": "integer",
              "description": "Estimated sum of recipient segments."
            },
            "pending_count": {
              "type": "integer",
              "description": "Rows pending or queued."
            },
            "segments_estimated": {
              "type": "boolean",
              "description": "Reported segments are estimates.",
              "const": true
            }
          },
          "required": [
            "campaign_id",
            "agent_id",
            "name",
            "from_number",
            "schedule_type",
            "scheduled_date",
            "window_start_minutes",
            "window_end_minutes",
            "window_days",
            "timezone",
            "source",
            "status",
            "total_count",
            "started_at",
            "completed_at",
            "created_at",
            "updated_at",
            "allow_wider_hours",
            "id",
            "api_key_id",
            "message_template",
            "reply_context_prompt",
            "reply_window_hours",
            "is_active",
            "claimed_at",
            "sent_count",
            "delivered_count",
            "failed_count",
            "reply_count",
            "total_segments",
            "pending_count",
            "segments_estimated"
          ],
          "description": "",
          "additionalProperties": false
        },
        "recipients": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "id": {
                "type": "string",
                "description": "Recipient row ID.",
                "format": "uuid"
              },
              "campaign_id": {
                "type": "string",
                "description": "Campaign ID."
              },
              "api_key_id": {
                "type": "string",
                "description": "Owner account ID."
              },
              "phone_number": {
                "type": "string",
                "description": "International number with + and digits; no spaces.",
                "pattern": "^\\+[1-9][0-9]{6,14}$"
              },
              "variables": {
                "type": "object",
                "properties": {},
                "description": "Saved template variables.",
                "additionalProperties": true
              },
              "rendered_message": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Rendered outgoing message."
              },
              "status": {
                "type": "string",
                "description": "Recipient state."
              },
              "segments_count": {
                "type": [
                  "integer",
                  "null"
                ],
                "description": "Estimated segment count."
              },
              "sent_at": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Saved timestamp, or null.",
                "format": "date-time"
              },
              "delivered_at": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Saved timestamp, or null.",
                "format": "date-time"
              },
              "replied_at": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Saved timestamp, or null.",
                "format": "date-time"
              },
              "error_message": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Saved failure explanation."
              },
              "created_at": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Saved timestamp, or null.",
                "format": "date-time"
              },
              "updated_at": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Saved timestamp, or null.",
                "format": "date-time"
              },
              "timezone": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Recipient time zone."
              },
              "country": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Recipient country."
              },
              "timezone_source": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Location evidence source."
              },
              "hold_reason": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Current contact hold."
              },
              "next_eligible_at": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Saved timestamp, or null.",
                "format": "date-time"
              }
            },
            "required": [
              "id",
              "campaign_id",
              "api_key_id",
              "phone_number",
              "variables",
              "rendered_message",
              "status",
              "segments_count",
              "sent_at",
              "delivered_at",
              "replied_at",
              "error_message",
              "created_at",
              "updated_at",
              "timezone",
              "country",
              "timezone_source",
              "hold_reason",
              "next_eligible_at"
            ],
            "description": "Recipient data; additional compatibility fields can be returned.",
            "additionalProperties": true
          },
          "description": ""
        },
        "messages": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "id": {
                "type": "string",
                "description": "Message row ID.",
                "format": "uuid"
              },
              "agent_id": {
                "type": "string",
                "description": "Agent ID."
              },
              "api_key_id": {
                "type": "string",
                "description": "Owner account ID."
              },
              "phone_number": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "International number with + and digits; no spaces.",
                "pattern": "^\\+[1-9][0-9]{6,14}$"
              },
              "from_number": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "International number with + and digits; no spaces.",
                "pattern": "^\\+[1-9][0-9]{6,14}$"
              },
              "to_number": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "International number with + and digits; no spaces.",
                "pattern": "^\\+[1-9][0-9]{6,14}$"
              },
              "direction": {
                "type": "string",
                "description": "Message direction."
              },
              "message": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Message text."
              },
              "campaign_id": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Associated campaign ID."
              },
              "segments_count": {
                "type": [
                  "integer",
                  "null"
                ],
                "description": "Estimated segments."
              },
              "sent_at": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Saved timestamp, or null.",
                "format": "date-time"
              },
              "delivered_at": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Saved timestamp, or null.",
                "format": "date-time"
              },
              "created_at": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Saved timestamp, or null.",
                "format": "date-time"
              },
              "context_type": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Reply context type."
              },
              "context_prompt": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Reply instructions."
              },
              "context_data": {
                "type": [
                  "object",
                  "null"
                ],
                "properties": {},
                "description": "Associated context.",
                "additionalProperties": true
              },
              "linked_call_id": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Linked call if present."
              },
              "delivery_status": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Saved delivery status."
              },
              "reply_to_sms_id": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Linked original message ID."
              }
            },
            "required": [
              "id",
              "agent_id",
              "api_key_id",
              "phone_number",
              "from_number",
              "to_number",
              "direction",
              "message",
              "campaign_id",
              "segments_count",
              "sent_at",
              "delivered_at",
              "created_at",
              "context_type",
              "context_prompt",
              "context_data",
              "linked_call_id",
              "delivery_status",
              "reply_to_sms_id"
            ],
            "description": "Message data; additional compatibility fields can be returned.",
            "additionalProperties": true
          },
          "description": ""
        },
        "pagination": {
          "type": "object",
          "properties": {
            "recipient_cursor": {
              "type": [
                "string",
                "null"
              ],
              "description": "Next recipient cursor."
            },
            "message_cursor": {
              "type": [
                "string",
                "null"
              ],
              "description": "Next message cursor."
            },
            "limit": {
              "type": "integer",
              "description": "Effective per-list page size."
            },
            "paged": {
              "type": "boolean",
              "description": "Whether explicit pagination was requested."
            }
          },
          "required": [
            "recipient_cursor",
            "message_cursor",
            "limit",
            "paged"
          ],
          "description": "",
          "additionalProperties": false
        }
      },
      "required": [
        "campaign",
        "recipients",
        "messages",
        "pagination"
      ],
      "description": "",
      "additionalProperties": false
    }
  },
  {
    "number": 186,
    "method": "GET",
    "path": "/v1/usage",
    "query": "",
    "schema": {
      "type": "object",
      "properties": {
        "plan": {
          "type": [
            "string",
            "null"
          ],
          "description": "Saved account plan label."
        },
        "total_calls": {
          "type": [
            "number",
            "null"
          ],
          "description": "Stored account call counter."
        },
        "total_minutes": {
          "type": [
            "number",
            "null"
          ],
          "description": "Stored account minutes; can be fractional."
        },
        "total_cost": {
          "type": [
            "number",
            "null"
          ],
          "description": "Stored account cost value; this is not an invoice or independent carrier charge total."
        },
        "rate_limit_per_minute": {
          "type": [
            "number",
            "null"
          ],
          "description": "Saved request limit. Request headers describe the effective limit."
        },
        "max_concurrent": {
          "type": "integer",
          "description": "Current configured call capacity; legacy fallback is 10 when no positive limit is stored.",
          "minimum": 0
        },
        "peak_concurrent_this_month": {
          "type": "integer",
          "description": "Observed monthly peak; legacy telemetry is best effort.",
          "minimum": 0
        },
        "rejected_at_cap_this_month": {
          "type": "integer",
          "description": "Recorded monthly refusals at capacity; best-effort telemetry can be zero when unavailable.",
          "minimum": 0
        },
        "occupied_call_slots": {
          "type": "integer",
          "description": "Optional owned reservation count, including unresolved reservations.",
          "minimum": 0
        },
        "capacity_source": {
          "type": "string",
          "description": "Present with owned-reservation capacity.",
          "const": "owned_reservations"
        },
        "capacity_measured_since": {
          "type": [
            "string",
            "null"
          ],
          "description": "Optional start of capacity measurement.",
          "format": "date-time"
        }
      },
      "required": [
        "plan",
        "total_calls",
        "total_minutes",
        "total_cost",
        "rate_limit_per_minute",
        "max_concurrent",
        "peak_concurrent_this_month",
        "rejected_at_cap_this_month"
      ],
      "description": "",
      "additionalProperties": false
    }
  },
  {
    "number": 187,
    "method": "GET",
    "path": "/v1/voices",
    "query": "?limit=1",
    "schema": {
      "type": "object",
      "properties": {
        "data": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "voice_key": {
                "type": "string",
                "description": "Stable neutral catalog identifier; use this value when selecting a voice."
              },
              "displayName": {
                "type": "string",
                "description": "Display label, not an identifier."
              },
              "gender": {
                "type": "string",
                "description": "Catalog gender label.",
                "enum": [
                  "male",
                  "female",
                  "unknown"
                ]
              },
              "nativeLanguage": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Native language code, when known."
              },
              "locale": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Locale label, when known."
              },
              "accents": {
                "type": "array",
                "items": {
                  "type": "object",
                  "properties": {
                    "language": {
                      "type": [
                        "string",
                        "null"
                      ],
                      "description": "Accent language. Null when not supplied in the catalog."
                    },
                    "locale": {
                      "type": [
                        "string",
                        "null"
                      ],
                      "description": "Accent locale."
                    },
                    "label": {
                      "type": [
                        "string",
                        "null"
                      ],
                      "description": "Neutral accent label. Null when not supplied in the catalog."
                    }
                  },
                  "required": [
                    "language",
                    "locale",
                    "label"
                  ],
                  "description": "",
                  "additionalProperties": false
                },
                "description": "Available accent labels."
              },
              "languages": {
                "type": "array",
                "items": {
                  "type": "string",
                  "description": "Approved language code."
                },
                "description": "Languages approved for this voice."
              },
              "origin": {
                "type": "string",
                "description": "Standard catalog or a connection belonging to this account.",
                "enum": [
                  "standard",
                  "connected"
                ]
              },
              "availability": {
                "type": "string",
                "description": "Current catalog availability.",
                "enum": [
                  "active",
                  "temporarily_unavailable",
                  "unavailable"
                ]
              },
              "selectable": {
                "type": "boolean",
                "description": "Whether a new selection is compatible with the supplied agent context."
              },
              "incompatibilityReason": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Reason when not selectable: voice_unavailable, voice_temporarily_unavailable, no_approved_languages, native_language_not_in_multi_set or language_not_approved. These are response values, not HTTP errors."
              },
              "previewLanguage": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Preview language, or null when no preview exists."
              },
              "previewStatus": {
                "type": "string",
                "description": "Preview state; none when no preview is available."
              },
              "previewUrl": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Preview URL when present. Null does not imply that the voice is unavailable."
              }
            },
            "required": [
              "voice_key",
              "displayName",
              "gender",
              "nativeLanguage",
              "locale",
              "accents",
              "languages",
              "origin",
              "availability",
              "selectable",
              "incompatibilityReason",
              "previewLanguage",
              "previewStatus",
              "previewUrl"
            ],
            "description": "",
            "additionalProperties": false
          },
          "description": "Visible voices on this page."
        },
        "next_cursor": {
          "type": [
            "string",
            "null"
          ],
          "description": "Continuation cursor, or null at the end. No total count is returned."
        }
      },
      "required": [
        "data",
        "next_cursor"
      ],
      "description": "",
      "additionalProperties": false
    }
  },
  {
    "number": 188,
    "method": "GET",
    "path": "/v1/voices/:voice_key",
    "query": "",
    "schema": {
      "type": "object",
      "properties": {
        "voice_key": {
          "type": "string",
          "description": "Stable neutral catalog identifier; use this value when selecting a voice."
        },
        "displayName": {
          "type": "string",
          "description": "Display label, not an identifier."
        },
        "gender": {
          "type": "string",
          "description": "Catalog gender label.",
          "enum": [
            "male",
            "female",
            "unknown"
          ]
        },
        "nativeLanguage": {
          "type": [
            "string",
            "null"
          ],
          "description": "Native language code, when known."
        },
        "locale": {
          "type": [
            "string",
            "null"
          ],
          "description": "Locale label, when known."
        },
        "accents": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "language": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Accent language. Null when not supplied in the catalog."
              },
              "locale": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Accent locale."
              },
              "label": {
                "type": [
                  "string",
                  "null"
                ],
                "description": "Neutral accent label. Null when not supplied in the catalog."
              }
            },
            "required": [
              "language",
              "locale",
              "label"
            ],
            "description": "",
            "additionalProperties": false
          },
          "description": "Available accent labels."
        },
        "languages": {
          "type": "array",
          "items": {
            "type": "string",
            "description": "Approved language code."
          },
          "description": "Languages approved for this voice."
        },
        "origin": {
          "type": "string",
          "description": "Standard catalog or a connection belonging to this account.",
          "enum": [
            "standard",
            "connected"
          ]
        },
        "availability": {
          "type": "string",
          "description": "Current catalog availability.",
          "enum": [
            "active",
            "temporarily_unavailable",
            "unavailable"
          ]
        },
        "selectable": {
          "type": "boolean",
          "description": "Whether a new selection is compatible with the supplied agent context."
        },
        "incompatibilityReason": {
          "type": [
            "string",
            "null"
          ],
          "description": "Reason when not selectable: voice_unavailable, voice_temporarily_unavailable, no_approved_languages, native_language_not_in_multi_set or language_not_approved. These are response values, not HTTP errors."
        },
        "previewLanguage": {
          "type": [
            "string",
            "null"
          ],
          "description": "Preview language, or null when no preview exists."
        },
        "previewStatus": {
          "type": "string",
          "description": "Preview state; none when no preview is available."
        },
        "previewUrl": {
          "type": [
            "string",
            "null"
          ],
          "description": "Preview URL when present. Null does not imply that the voice is unavailable."
        }
      },
      "required": [
        "voice_key",
        "displayName",
        "gender",
        "nativeLanguage",
        "locale",
        "accents",
        "languages",
        "origin",
        "availability",
        "selectable",
        "incompatibilityReason",
        "previewLanguage",
        "previewStatus",
        "previewUrl"
      ],
      "description": "",
      "additionalProperties": false
    }
  },
  {
    "number": 192,
    "method": "GET",
    "path": "/v1/agents/:target/knowledge-keyterms",
    "query": "",
    "sourceSupplement": "B49g metadata from pinned knowledge/reads.js; C8 schema describes only the list",
    "schema": {
      "type": "object",
      "properties": {
        "knowledge_keyterms": {
          "type": "array",
          "items": {
            "type": "string",
            "description": "Source-spelled term."
          },
          "description": "Ranked automatic candidates; default cap 80 per agent, operator-configurable from 0 to 100.",
          "maxItems": 100
        },
        "knowledge_keyterms_count": {
          "type": "integer",
          "minimum": 0,
          "description": "Length of knowledge_keyterms."
        },
        "knowledge_keyterms_limit": {
          "type": "integer",
          "minimum": 0,
          "maximum": 100,
          "description": "Configured automatic candidate limit; default 80."
        },
        "manual_keyterms": {
          "type": "array",
          "items": {
            "type": "string"
          },
          "description": "Saved customer entries, trimmed and nonempty. Compare with unsaved form values in your UI."
        },
        "manual_keyterms_count": {
          "type": "integer",
          "minimum": 0,
          "description": "Length of manual_keyterms; an unchanged legacy list can exceed today’s edit limit."
        },
        "manual_keyterms_limit": {
          "type": "integer",
          "const": 20,
          "description": "Maximum nonempty terms for newly edited manual lists; unchanged saved lists may exceed this value."
        }
      },
      "required": [
        "knowledge_keyterms",
        "knowledge_keyterms_count",
        "knowledge_keyterms_limit",
        "manual_keyterms",
        "manual_keyterms_count",
        "manual_keyterms_limit"
      ],
      "additionalProperties": true,
      "description": ""
    }
  },
  {
    "number": 194,
    "method": "GET",
    "path": "/v1/integrations/google-calendar/number/:phoneNumber",
    "query": "",
    "schema": {
      "type": "object",
      "properties": {
        "connected": {
          "type": "boolean"
        },
        "account_email": {
          "type": [
            "string",
            "null"
          ]
        },
        "calendar_id": {
          "type": "string"
        },
        "connected_at": {
          "type": [
            "string",
            "null"
          ],
          "format": "date-time"
        },
        "needs_reconnect": {
          "type": "boolean"
        },
        "send_invites": {
          "type": "boolean"
        }
      },
      "required": [
        "connected",
        "account_email",
        "calendar_id",
        "connected_at",
        "needs_reconnect",
        "send_invites"
      ]
    }
  }
]
'@ | ConvertFrom-Json
$script:Pass=0;$script:Fail=0;$script:Pending=0
$script:Http=0;$script:Phase='guard';$script:Retried=$false
$script:Retired=@(
 [pscustomobject]@{Path='/v1/account/delete';Code='dashboard_owner_required';Auth=$false},
 [pscustomobject]@{Path='/v1/numbers/not-a-number/knowledge-base';Code='number_knowledge_removed';Auth=$true},
 [pscustomobject]@{Path='/v1/agents/not-an-agent/knowledge-numbers';Code='number_knowledge_removed';Auth=$true},
 [pscustomobject]@{Path='/v1/knowledge/targets?kind=number';Code='number_knowledge_removed';Auth=$true}
)
function Assert-C8($Condition){if(-not $Condition){throw 'C8 assertion failed; values withheld'}}
function Field-C8($Value,[string]$Name){if($null -eq $Value){return $null};$p=$Value.PSObject.Properties[$Name];if($null -eq $p){return $null};return $p.Value}
function Match-C8([string]$Template,[string]$Path){$pattern=[regex]::Replace([regex]::Escape($Template),':([A-Za-z_]+)','[^/?#]+');return $Path -cmatch ('^'+$pattern+'(?:\?[^#]*)?$')}
function Guard-C8([string]$Method,[string]$Path){
 Assert-C8 ($Method -ceq 'GET')
 Assert-C8 ($Path -cmatch '^/v1/[A-Za-z0-9_/%+:?.=&,-]+$')
 $decoded=$Path
 for($i=0;$i -lt 4;$i++){$decoded=[uri]::UnescapeDataString($decoded)}
 Assert-C8 ($decoded -notmatch '447861926140|447457401554|pickup_delay|\.\.|://|[\r\n#]')
 Assert-C8 ($decoded -notmatch '/drafts/|/signing-secret|refresh_cards')
 $allowed=$false
 foreach($case in $script:Cases){if(Match-C8 $case.path $Path){$allowed=$true;break}}
 foreach($case in $script:Retired){if($case.Path -ceq $Path){$allowed=$true;break}}
 Assert-C8 $allowed
}
function HttpError-C8($Record){
 $response=$Record.Exception.Response
 if($null -eq $response){return [pscustomobject]@{Status=0;Content='';Source='transport'}}
 $content='';$source='stream'
 if($Record.ErrorDetails -and -not [string]::IsNullOrWhiteSpace($Record.ErrorDetails.Message)){$content=[string]$Record.ErrorDetails.Message;$source='ErrorDetails.Message'}
 else {try{$reader=New-Object IO.StreamReader($response.GetResponseStream());try{$content=$reader.ReadToEnd()}finally{$reader.Dispose()}}catch{$content=''}}
 return [pscustomobject]@{Status=[int]$response.StatusCode;Content=$content;Source=$source}
}
function Request-C8([string]$Path,[bool]$Authenticated=$true){
 $script:Http=0;$script:Phase='guard';$script:Retried=$false
 Guard-C8 'GET' $Path
 $headers=@{}
 if($Authenticated){Assert-C8 (-not [string]::IsNullOrWhiteSpace($env:NXF_STAGING_KEY));$headers.Authorization='Bearer '+$env:NXF_STAGING_KEY}
 # Fixed origin, GET, no body, no redirect, no connection reuse. No signed URL follow.
 $request=@{Uri=($script:C8Base+$Path);Method='GET';Headers=$headers;UseBasicParsing=$true;DisableKeepAlive=$true;MaximumRedirection=0;TimeoutSec=30;ErrorAction='Stop'}
 $status=0;$content='';$source='success';$script:Phase='request'
 for($attempt=0;$attempt -lt 2;$attempt++){
  try{$r=Invoke-WebRequest @request;$status=[int]$r.StatusCode;$content=[string]$r.Content;$source='success'}catch{$e=HttpError-C8 $_;$status=$e.Status;$content=$e.Content;$source=$e.Source}
  if($status -eq 0 -and $attempt -eq 0){$script:Retried=$true;Write-Host 'INFO | GET HTTP=0 | one retry after 500 ms';Start-Sleep -Milliseconds 500;continue};break
 }
 $script:Http=$status;$script:Phase='parse';$json=$null
 if($content){try{$json=ConvertFrom-Json -InputObject $content}catch{throw 'Response was not JSON; withheld'}}
 return [pscustomobject]@{Status=$status;Json=$json;RootArray=$content.TrimStart().StartsWith('[');ErrorSource=$source}
}
function Shape-C8($Value,$Schema,[int]$Depth=0){
 Assert-C8 ($Depth -le 30)
 foreach($s in @(Field-C8 $Schema 'allOf')){if($s){Shape-C8 $Value $s ($Depth+1)}}
 $branches=Field-C8 $Schema 'anyOf';if(-not $branches){$branches=Field-C8 $Schema 'oneOf'}
 if($branches){$valid=$false;foreach($s in $branches){try{Shape-C8 $Value $s ($Depth+1);$valid=$true;break}catch{}};Assert-C8 $valid;return}
 $types=@(Field-C8 $Schema 'type')
 if($null -eq $Value){Assert-C8 (($types -contains 'null') -or -not $types[0]);return}
 if($types -contains 'object'){
  Assert-C8 ($Value -is [pscustomobject])
  foreach($f in @(Field-C8 $Schema 'required')){if($f){Assert-C8 ($null -ne $Value.PSObject.Properties[$f])}}
  $props=Field-C8 $Schema 'properties'
  if($props){foreach($p in $props.PSObject.Properties){if($null -ne $Value.PSObject.Properties[$p.Name]){Shape-C8 $Value.PSObject.Properties[$p.Name].Value $p.Value ($Depth+1)}}}
 }elseif($types -contains 'array'){
  Assert-C8 ($Value -is [array]);$items=Field-C8 $Schema 'items';if($items){foreach($v in $Value){Shape-C8 $v $items ($Depth+1)}}
 }elseif($types -contains 'string'){Assert-C8 ($Value -is [string])}
 elseif($types -contains 'boolean'){Assert-C8 ($Value -is [bool])}
 elseif($types -contains 'integer'){Assert-C8 ($Value -is [int] -or $Value -is [long])}
 elseif($types -contains 'number'){Assert-C8 ($Value -is [ValueType] -and $Value -isnot [bool])}
 $values=Field-C8 $Schema 'enum';if($values){Assert-C8 ($Value -cin $values)}
}
function WireShape-C8($Response,$Schema){
 # PS5 unwraps root JSON arrays. Restore from the wire flag, never treat object as array.
 $value=$Response.Json
 if($Response.RootArray){if($null -eq $value){$value=@()}else{$value=@($value)}}
 Shape-C8 $value $Schema
}
function CallerAbsent-C8($Response){return ($Response.Status -eq 404 -and (Field-C8 (Field-C8 $Response.Json 'error') 'code') -ceq 'caller_not_found')}
function Pending-C8([string]$Name,[string]$Why){$script:Pending++;Write-Output ('PENDING | '+$Name+' | pending manual test: '+$Why)}
function Result-C8([string]$Name,[bool]$Ok){
 $label='FAIL';if($Ok){$script:Pass++;$label='PASS'}else{$script:Fail++}
 Write-Output ($label+' | '+$Name+' | HTTP='+$script:Http+' phase='+$script:Phase+' retried='+$script:Retried.ToString().ToLowerInvariant()+' | values withheld')
}
if($LoadFunctionsOnly){return}
[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12
$hasKey=-not [string]::IsNullOrWhiteSpace($env:NXF_STAGING_KEY)
$fixture=@{agent='';number='';thread='';campaign='';call='';voice='';kb='';topic='';caller=$env:NXF_C8_CALLER_NUMBER;job=$env:NXF_C8_JOB_ID;export=$env:NXF_C8_EXPORT_ID;session=$env:NXF_C8_SESSION_ID}
if(-not $fixture.caller){$fixture.caller='+12025550101'}
$cache=@{}
function Discover-C8([string]$Path){
 try{$r=Request-C8 $Path;$cache[$Path]=$r;if($r.Status -eq 200){return ,$r.Json}}catch{}
 return $null
}
if($hasKey){
 $agents=Discover-C8 '/v1/agents?limit=1'
 if($env:NXF_C8_AGENT_ID){
  $a=Discover-C8 ('/v1/agents/'+[uri]::EscapeDataString($env:NXF_C8_AGENT_ID))
  if($a -and ($a|ConvertTo-Json -Depth 20 -Compress) -notmatch '447861926140|447457401554'){$fixture.agent=[string](Field-C8 $a 'agent_id')}
 }else{
  foreach($a in @($agents)){if($null -ne $a -and ($a|ConvertTo-Json -Depth 20 -Compress) -notmatch '447861926140|447457401554'){$fixture.agent=[string](Field-C8 $a 'agent_id');if($fixture.agent){break}}}
 }
 $numbers=Discover-C8 '/v1/phone-numbers?limit=100'
 # Select only a number proved owned by GET phone-numbers; never take ownership from inbox data.
 foreach($n in @(Field-C8 $numbers 'phone_numbers')){
  $candidate=[string](Field-C8 $n 'phone_number')
  if($candidate -cmatch '^\+[1-9][0-9]{6,14}$' -and $candidate -notmatch '447861926140|447457401554' -and (-not $env:NXF_C8_NUMBER -or $env:NXF_C8_NUMBER -ceq $candidate)){$fixture.number=$candidate;break}
 }
 $voices=Discover-C8 '/v1/voices?limit=1';$rows=@(Field-C8 $voices 'data');if($rows.Count -gt 0){$fixture.voice=[string](Field-C8 $rows[0] 'voice_key')}
 $campaigns=Discover-C8 '/v1/sms/campaigns?limit=2';foreach($c in @(Field-C8 $campaigns 'campaigns')){if($c -and ($c|ConvertTo-Json -Depth 20 -Compress) -notmatch '447861926140|447457401554'){$fixture.campaign=[string](Field-C8 $c 'campaign_id');break}}
 $calls=Discover-C8 '/v1/calls/history?period=all&limit=20'
 foreach($c in @(Field-C8 $calls 'data')){
  if(-not $c -or -not $fixture.number){continue}
  $j=$c|ConvertTo-Json -Depth 20 -Compress
  if($j -notmatch '447861926140|447457401554' -and $j.Contains($fixture.number)){$fixture.call=[string](Field-C8 $c 'call_id');if($fixture.call){break}}
 }
 if($fixture.number){$threads=Discover-C8 ('/v1/agent-inbox/web/'+[uri]::EscapeDataString($fixture.number)+'?limit=2&period=all');$rows=@(Field-C8 $threads 'conversations');if($rows.Count -gt 0){$fixture.thread=[string](Field-C8 $rows[0] 'thread_key')}}
 if($fixture.agent){$scope=Discover-C8 ('/v1/agents/'+[uri]::EscapeDataString($fixture.agent)+'/knowledge-base');$fixture.kb=[string](Field-C8 (Field-C8 $scope 'own') 'id')}
 if($fixture.kb){$topics=Discover-C8 ('/v1/knowledge-bases/'+[uri]::EscapeDataString($fixture.kb)+'/topics?limit=2');$rows=@(Field-C8 $topics 'items');if($rows.Count -gt 0){$fixture.topic=[string](Field-C8 $rows[0] 'id')}}
}
foreach($case in $script:Cases){
 $name='row '+$case.number+' GET shape'
 if(-not $hasKey){Pending-C8 $name 'C8 NXF_STAGING_KEY is absent';continue}
 $path=$case.path;$missing=$false
 foreach($p in [regex]::Matches($path,':([A-Za-z_]+)')){
  $value=''
  switch -CaseSensitive ($p.Groups[1].Value){
   'channel'{$value='web'} 'number'{$value=$fixture.number} 'phoneNumber'{$value=$fixture.number} 'callerNumber'{$value=$fixture.caller}
   'thread'{$value=$fixture.thread} 'target'{$value=$fixture.agent} 'agentId'{$value=$fixture.agent} 'voice_key'{$value=$fixture.voice} 'kb'{$value=$fixture.kb}
   'id'{switch($case.number){63{$value=$fixture.agent} 87{$value=$fixture.call} 89{$value=$fixture.call} 121{$value=$fixture.topic} 128{$value=$fixture.export} 129{$value=$fixture.job} 133{$value=$fixture.session} 178{$value=$fixture.campaign}}}
  }
  if(-not $value -or $value -match '447861926140|447457401554'){$missing=$true;break}
  $path=$path.Replace($p.Value,[uri]::EscapeDataString($value))
 }
 if($missing){Pending-C8 $name 'owned fixture unavailable; no guessed IDs';continue}
 $query=$case.query
 if($case.number -eq 57){if(-not $fixture.number){Pending-C8 $name 'C8 number required';continue};$query='?number='+[uri]::EscapeDataString($fixture.number)}
 try{
  $r=Request-C8 ($path+$query)
  $code=Field-C8 (Field-C8 $r.Json 'error') 'code'
  if($case.number -eq 170 -and -not $env:NXF_C8_CALLER_NUMBER){$script:Phase='caller-absence';Assert-C8 (CallerAbsent-C8 $r);Result-C8 ('row 170 caller_not_found refusal') $true;continue}
  if(($r.Status -eq 404 -and $case.number -in @(66,103,109,111,118,121,123,126,127,128,129,132,133,136,143,145,152,192)) -or ($r.Status -in @(409,503) -and $code -cin @('agent_inbox_disabled','knowledge_not_released','knowledge_unconfigured','knowledge_missing','export_expired'))){Pending-C8 $name ('feature or fixture unavailable; HTTP='+$r.Status);continue}
  $script:Phase='status';Assert-C8 ($r.Status -eq 200);$script:Phase='shape';WireShape-C8 $r $case.schema
  if($case.number -eq 55){Assert-C8 ($r.Json.enabled -is [bool])}
  if($case.number -eq 192){Assert-C8 ($r.Json.knowledge_keyterms_count -eq @($r.Json.knowledge_keyterms).Count -and $r.Json.manual_keyterms_count -eq @($r.Json.manual_keyterms).Count -and $r.Json.manual_keyterms_limit -eq 20)}
  Result-C8 $name $true
 }catch{Result-C8 $name $false}
}
foreach($case in $script:Retired){
 $name='retired GET '+$case.Path
 if($case.Auth -and -not $hasKey){Pending-C8 $name 'C8 key required to reach retirement guard';continue}
 try{
  $r=Request-C8 $case.Path $case.Auth
  if($case.Auth -and $r.Status -in @(404,503)){Pending-C8 $name ('knowledge unavailable; 410 not proven; HTTP='+$r.Status);continue}
  $script:Phase='retirement-status'
  Assert-C8 ($r.Status -eq 410 -and (Field-C8 (Field-C8 $r.Json 'error') 'code') -ceq $case.Code)
  Result-C8 $name $true
 }catch{Result-C8 $name $false}
}
Pending-C8 'row 105 legacy draft GET' 'can save legacy repairs; excluded'
Pending-C8 'row 158 signing secret GET' 'private Owner dashboard retrieval; never collected by this script'
foreach($name in @('row 1 POST /v1/keys',
 'row 2 POST /v1/keys/rotate',
 'row 12 PUT /v1/integrations/calcom/number/:phoneNumber',
 'row 14 DELETE /v1/integrations/calcom/number/:phoneNumber',
 'row 15 PUT /v1/integrations/slack/number/:phoneNumber',
 'row 17 DELETE /v1/integrations/slack/number/:phoneNumber',
 'row 18 PUT /v1/integrations/zapier/number/:phoneNumber',
 'row 20 DELETE /v1/integrations/zapier/number/:phoneNumber',
 'row 21 PUT /v1/integrations/make/number/:phoneNumber',
 'row 23 DELETE /v1/integrations/make/number/:phoneNumber',
 'row 24 PUT /v1/integrations/gohighlevel/number/:phoneNumber',
 'row 26 DELETE /v1/integrations/gohighlevel/number/:phoneNumber',
 'row 27 PUT /v1/integrations/webhook/number/:phoneNumber',
 'row 29 DELETE /v1/integrations/webhook/number/:phoneNumber',
 'row 30 PUT /v1/integrations/webhook2/number/:phoneNumber',
 'row 36 PUT /v1/integrations/web-calls/number/:phoneNumber',
 'row 38 DELETE /v1/integrations/web-calls/number/:phoneNumber',
 'row 39 DELETE /v1/integrations/webhook2/number/:phoneNumber',
 'row 40 PUT /v1/integrations/precall/number/:phoneNumber',
 'row 42 DELETE /v1/integrations/precall/number/:phoneNumber',
 'row 43 PUT /v1/integrations/precall/agent/:agentId',
 'row 45 DELETE /v1/integrations/precall/agent/:agentId',
 'row 46 POST /v1/integrations/custom-functions/number/:phoneNumber',
 'row 48 DELETE /v1/integrations/custom-functions/number/:phoneNumber/:id',
 'row 49 PATCH /v1/integrations/custom-functions/number/:phoneNumber/:id',
 'row 54 PATCH /v1/agent-inbox/:channel/:number/thread/:thread',
 'row 59 PATCH /v1/agent-web/:number',
 'row 61 POST /v1/agents',
 'row 62 DELETE /v1/agents/:id',
 'row 64 PUT /v1/agents/:id',
 'row 65 DELETE /v1/agents/:target/knowledge-base',
 'row 67 PUT /v1/agents/:target/knowledge-base',
 'row 69 POST /v1/agents/:target/knowledge-base/source-measure',
 'row 70 POST /v1/agents/:target/knowledge-base/test-sessions',
 'row 83 DELETE /v1/calls',
 'row 86 DELETE /v1/calls/:id',
 'row 90 POST /v1/calls/batch',
 'row 91 POST /v1/calls/batch/:id/cancel',
 'row 92 POST /v1/calls/batch/:id/consent',
 'row 93 POST /v1/calls/batch/:id/launch',
 'row 94 POST /v1/calls/batch/:id/resume',
 'row 96 POST /v1/calls/outbound',
 'row 98 POST /v1/contact-hours/preview',
 'row 99 DELETE /v1/contact-suppressions',
 'row 101 POST /v1/contact-suppressions',
 'row 104 DELETE /v1/knowledge-bases/:kb/drafts/:id',
 'row 106 PATCH /v1/knowledge-bases/:kb/drafts/:id',
 'row 107 POST /v1/knowledge-bases/:kb/drafts/:id/accept',
 'row 108 POST /v1/knowledge-bases/:kb/exports',
 'row 110 PATCH /v1/knowledge-bases/:kb/settings',
 'row 112 POST /v1/knowledge-bases/:kb/sources',
 'row 113 DELETE /v1/knowledge-bases/:kb/sources/:id',
 'row 114 PATCH /v1/knowledge-bases/:kb/sources/:id',
 'row 115 POST /v1/knowledge-bases/:kb/sources/:id/replacements',
 'row 116 POST /v1/knowledge-bases/:kb/sources/refresh',
 'row 117 POST /v1/knowledge-bases/:kb/topic-search',
 'row 119 POST /v1/knowledge-bases/:kb/topics',
 'row 120 DELETE /v1/knowledge-bases/:kb/topics/:id',
 'row 122 PATCH /v1/knowledge-bases/:kb/topics/:id',
 'row 124 POST /v1/knowledge-bases/:kb/website-discoveries',
 'row 125 POST /v1/knowledge-bases/:kb/website-imports',
 'row 130 POST /v1/knowledge/jobs/:id/cancel',
 'row 131 POST /v1/knowledge/jobs/:id/retry',
 'row 134 POST /v1/knowledge/test-sessions/:id/cancel',
 'row 135 POST /v1/knowledge/test-sessions/:id/messages',
 'row 146 POST /v1/organisation/claim-invite',
 'row 148 POST /v1/organisation/invites',
 'row 149 DELETE /v1/organisation/invites/:id',
 'row 150 POST /v1/organisation/invites/:id/resend',
 'row 153 DELETE /v1/organisation/members/:id',
 'row 154 PATCH /v1/organisation/members/:id',
 'row 155 PATCH /v1/organisation/name',
 'row 165 POST /v1/phone-numbers',
 'row 166 DELETE /v1/phone-numbers/:phoneNumber',
 'row 168 PATCH /v1/phone-numbers/:phoneNumber',
 'row 169 DELETE /v1/phone-numbers/:phoneNumber/callers/:callerNumber',
 'row 171 PUT /v1/phone-numbers/:phoneNumber/callers/:callerNumber',
 'row 172 POST /v1/phone-numbers/:phoneNumber/callers/import',
 'row 174 POST /v1/sms',
 'row 176 POST /v1/sms/campaigns',
 'row 177 DELETE /v1/sms/campaigns/:id',
 'row 179 PATCH /v1/sms/campaigns/:id',
 'row 180 POST /v1/sms/campaigns/:id/cancel',
 'row 181 POST /v1/sms/campaigns/:id/consent',
 'row 182 POST /v1/sms/campaigns/:id/launch',
 'row 183 POST /v1/sms/campaigns/:id/resume',
 'row 193 POST /v1/integrations/google-calendar/number/:phoneNumber/connect',
 'row 195 DELETE /v1/integrations/google-calendar/number/:phoneNumber',
 'row 196 PATCH /v1/integrations/google-calendar/number/:phoneNumber',
 'row 197 POST /v1/phone-numbers/:phoneNumber/credentials')){Pending-C8 $name 'successful write or calculation excluded; GET-only runner'}
Write-Output ('TOTAL | PASS='+$script:Pass+' FAIL='+$script:Fail+' PENDING='+$script:Pending)
if($script:Fail -gt 0){exit 1}
