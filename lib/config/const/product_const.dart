class ApiConstants {
  static const _supabaseUrl = 'https://bnbiejkxjbplqdankvyz.supabase.co';
  static const _anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJuYmllamt4amJwbHFkYW5rdnl6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU5MjU1NjgsImV4cCI6MjA5MTUwMTU2OH0.AByQNNcOrBFSk3cMyWQ2syrWyI7r0bvGc8ypTiNOs7s';

  static const products   = '$_supabaseUrl/rest/v1/products';
  static const addProduct = products;

  static const headers = {
    'Content-Type':  'application/json',
    'apikey':        _anonKey,
    'Authorization': 'Bearer $_anonKey',
    'Prefer':        'return=representation',
  };
}