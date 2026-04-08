class AIConfig {
  static const String openaiApiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const String openaiModel = String.fromEnvironment('OPENAI_MODEL', defaultValue: 'gpt-4o-mini');
}
