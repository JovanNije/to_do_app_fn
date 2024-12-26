import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiController {
  final String baseUrl = 'http://localhost/api';

  Future<void> testApiConnection() async {
    const String apiUrl = 'http://localhost/api/tasks';
    
    try {
      final response = await http.get(Uri.parse(apiUrl));
      
      if (response.statusCode == 200) {
        print('Connection successful: ${response.body}');
      } else {
        print('Connection failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Connection error: $e');
    }
  }

  // Fetch all tasks
  Future<List<Map<String, dynamic>>> fetchTasks() async {
    final url = Uri.parse('$baseUrl/tasks');
    
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((task) => Map<String, dynamic>.from(task)).toList();
    } else {
      throw Exception('Failed to fetch tasks: ${response.body}');
    }
  }

  // Method to add a task
  Future<Map<String, dynamic>> addTask(String name, String description) async {
    final url = Uri.parse('$baseUrl/tasks');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json', // Set Content-Type header
      },
      body: jsonEncode({
        "name": name,
        "description": description,
        "isFavorite": false, // Default value for isfavorite
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add task: ${response.body}');
    }
  }

  // Method to delete a task
  Future<void> deleteTask(int taskId) async {
    final url = Uri.parse('$baseUrl/tasks/$taskId'); // Add task ID to the URL
    
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json', // Set Content-Type header
      },
    );

    if (response.statusCode == 200) {
      // Check if the response body is empty or not
      if (response.body.isEmpty) {
        // Handle case where there is no body returned
        print('Task deleted successfully, but no content returned.');
      } else {
        // If there is content, decode the JSON (if necessary)
        var jsonResponse = jsonDecode(response.body);
        print('Task deleted successfully. Response: $jsonResponse');
      }
    } else {
      throw Exception('Failed to delete task: ${response.body}');
    }
  }

Future<Map<String, dynamic>> updateTask(int taskId, String name, String description, bool isFavorite) async {
  final url = Uri.parse('$baseUrl/tasks/$taskId'); // Add task ID to the URL

  final response = await http.put(
    url,
    headers: {
      'Content-Type': 'application/json', // Set Content-Type header
    },
    body: jsonEncode({
      "name": name,
      "description": description,
      "isFavorite": isFavorite, // Send the boolean value (true/false) with the correct casing
    }),
  );

  if (response.statusCode == 200) {
    // Parse and return the JSON response
    return jsonDecode(response.body) as Map<String, dynamic>;
  } else {
    throw Exception('Failed to update task: ${response.statusCode}');
  }
}


}
