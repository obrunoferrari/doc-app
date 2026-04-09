import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

// Constante com a URL base da API
const String apiBaseUrl =
    'http://doc-backend-uat.eba-xkszcebf.us-east-2.elasticbeanstalk.com/api';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doc',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse('$apiBaseUrl/auth/login');

      final body = jsonEncode({
        'username': _usernameController.text,
        'password': _passwordController.text,
      });

      print('Enviando requisição para: $url');
      print('Body: $body');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final profissionalId = data['profissional'];

        if (!mounted) return;

        print('Token recebido completo: $token');
        print('ID do profissional: $profissionalId');

        // Navegar para a tela principal
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                HomeScreen(token: token, profissionalId: profissionalId),
          ),
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fazer login: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Erro na requisição: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo maior
              Image.asset(
                'assets/images/logo.jpeg',
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 32),

              Text(
                'Faça login para continuar',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),

              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Usuário',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Entrar', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OnboardingScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Criar conta',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// ==================== TELA HOME ====================

class HomeScreen extends StatelessWidget {
  final String token;
  final int profissionalId;

  const HomeScreen({
    super.key,
    required this.token,
    required this.profissionalId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Botão Pacientes
              SizedBox(
                width: double.infinity,
                height: 120,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PacientesScreen(
                          token: token,
                          profissionalId: profissionalId,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.people, size: 36),
                  label: const Text(
                    'Pacientes',
                    style: TextStyle(fontSize: 22),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Botão Capturar Mídia
              SizedBox(
                width: double.infinity,
                height: 120,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navegar para tela de captura
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Capturar Mídia - Em desenvolvimento'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.camera_alt, size: 36),
                  label: const Text(
                    'Capturar Mídia',
                    style: TextStyle(fontSize: 22),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Botão Sair
              SizedBox(
                width: double.infinity,
                height: 120,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.exit_to_app, size: 36),
                  label: const Text('Sair', style: TextStyle(fontSize: 22)),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== TELA DE ONBOARDING ====================

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  String nome = '';
  int? especialidadeId;
  String? especialidadeNome;
  int? localidadeId;
  String? localidadeCidade;
  String? localidadeEstado;
  String usuario = '';
  String senha = '';

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Conta'), elevation: 0),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentPage + 1) / 5,
            backgroundColor: Colors.grey[200],
            minHeight: 8,
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Passo ${_currentPage + 1} de 5',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                OnboardingPage1(
                  initialValue: nome,
                  onNext: (value) {
                    setState(() {
                      nome = value;
                    });
                    _nextPage();
                  },
                ),
                OnboardingPage2(
                  selectedId: especialidadeId,
                  onNext: (id, nomeSelecionado) {
                    setState(() {
                      especialidadeId = id;
                      especialidadeNome = nomeSelecionado;
                    });
                    _nextPage();
                  },
                  onBack: _previousPage,
                ),
                OnboardingPage3(
                  selectedId: localidadeId,
                  onNext: (id, cidade, estado) {
                    setState(() {
                      localidadeId = id;
                      localidadeCidade = cidade;
                      localidadeEstado = estado;
                    });
                    _nextPage();
                  },
                  onBack: _previousPage,
                ),
                OnboardingPage4(
                  initialUsuario: usuario,
                  initialSenha: senha,
                  onNext: (user, pass) {
                    setState(() {
                      usuario = user;
                      senha = pass;
                    });
                    _nextPage();
                  },
                  onBack: _previousPage,
                ),
                OnboardingPage5(
                  nome: nome,
                  especialidade: especialidadeNome ?? '',
                  localidade: '$localidadeCidade - $localidadeEstado',
                  usuario: usuario,
                  onConfirm: () async {
                    await _finalizarOnboarding();
                  },
                  onBack: _previousPage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _finalizarOnboarding() async {
    try {
      final url = Uri.parse('$apiBaseUrl/onboard');

      final body = jsonEncode({
        'nome': nome,
        'localidade': localidadeId,
        'especialidade': especialidadeId,
        'usuario': usuario,
        'senha': senha,
      });

      print('Enviando onboarding: $body');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar conta: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Erro: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

// ==================== PÁGINA 1: NOME ====================

class OnboardingPage1 extends StatefulWidget {
  final String initialValue;
  final Function(String) onNext;

  const OnboardingPage1({
    super.key,
    required this.initialValue,
    required this.onNext,
  });

  @override
  State<OnboardingPage1> createState() => _OnboardingPage1State();
}

class _OnboardingPage1State extends State<OnboardingPage1> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.person, size: 80, color: Colors.blue),
          const SizedBox(height: 24),

          Text(
            'Qual é o seu nome completo?',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Nome completo',
              prefixIcon: const Icon(Icons.badge),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                if (_controller.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor, informe seu nome'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                widget.onNext(_controller.text.trim());
              },
              child: const Text('Continuar', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// ==================== PÁGINA 2: ESPECIALIDADE ====================

class OnboardingPage2 extends StatefulWidget {
  final int? selectedId;
  final Function(int, String) onNext;
  final VoidCallback onBack;

  const OnboardingPage2({
    super.key,
    required this.selectedId,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<OnboardingPage2> createState() => _OnboardingPage2State();
}

class _OnboardingPage2State extends State<OnboardingPage2> {
  List<dynamic> _especialidades = [];
  bool _isLoading = true;
  int? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.selectedId;
    _carregarEspecialidades();
  }

  Future<void> _carregarEspecialidades() async {
    try {
      final url = Uri.parse('$apiBaseUrl/especialidade');
      final response = await http.get(url);

      print('Especialidades status: ${response.statusCode}');
      print('Especialidades body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          _especialidades = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar especialidades: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Icon(Icons.medical_services, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              Text(
                'Qual é a sua especialidade?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),

        if (_isLoading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _especialidades.length,
              itemBuilder: (context, index) {
                final esp = _especialidades[index];
                return Card(
                  child: RadioListTile<int>(
                    title: Text(esp['nome']),
                    value: esp['id'],
                    groupValue: _selectedId,
                    onChanged: (value) {
                      setState(() {
                        _selectedId = value;
                      });
                    },
                  ),
                );
              },
            ),
          ),

        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onBack,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 50),
                  ),
                  child: const Text('Voltar'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedId == null
                      ? null
                      : () {
                          final selected = _especialidades.firstWhere(
                            (e) => e['id'] == _selectedId,
                          );
                          widget.onNext(_selectedId!, selected['nome']);
                        },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 50),
                  ),
                  child: const Text('Continuar'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==================== TELA DE PACIENTES ====================

class PacientesScreen extends StatefulWidget {
  final String token;
  final int profissionalId;

  const PacientesScreen({
    super.key,
    required this.token,
    required this.profissionalId,
  });

  @override
  State<PacientesScreen> createState() => _PacientesScreenState();
}

class _PacientesScreenState extends State<PacientesScreen> {
  List<dynamic> _pacientes = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _carregarPacientes();
  }

  Future<void> _carregarPacientes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final url = Uri.parse(
        '$apiBaseUrl/media/professional/${widget.profissionalId}',
      );

      print('Carregando pacientes: $url');
      print('Token: ${widget.token}');

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          _pacientes = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Erro ao carregar pacientes: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erro: $e');
      setState(() {
        _errorMessage = 'Erro de conexão: $e';
        _isLoading = false;
      });
    }
  }

  int _calcularIdade(String dataNascimento) {
    try {
      final nascimento = DateTime.parse(dataNascimento);
      final hoje = DateTime.now();
      int idade = hoje.year - nascimento.year;

      if (hoje.month < nascimento.month ||
          (hoje.month == nascimento.month && hoje.day < nascimento.day)) {
        idade--;
      }

      return idade;
    } catch (e) {
      return 0;
    }
  }

  String _getGeneroTexto(int genero) {
    return genero == 0 ? 'Masculino' : 'Feminino';
  }

  IconData _getGeneroIcone(int genero) {
    return genero == 0 ? Icons.male : Icons.female;
  }

  Color _getGeneroColor(int genero) {
    return genero == 0 ? Colors.blue : Colors.pink;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pacientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarPacientes,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _carregarPacientes,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            )
          : _pacientes.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum paciente encontrado',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _carregarPacientes,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _pacientes.length,
                itemBuilder: (context, index) {
                  final paciente = _pacientes[index];
                  final idade = _calcularIdade(paciente['data_nascimento']);
                  final genero = paciente['genero'];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        // TODO: Navegar para detalhes do paciente
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Detalhes de ${paciente['nome']}'),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nome e ícone de gênero
                            Row(
                              children: [
                                Icon(
                                  _getGeneroIcone(genero),
                                  color: _getGeneroColor(genero),
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    paciente['nome'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey[400],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Informações
                            Row(
                              children: [
                                Icon(
                                  Icons.cake,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$idade anos',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Icon(
                                  Icons.wc,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _getGeneroTexto(genero),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${paciente['localidade']['cidade']} - ${paciente['localidade']['estado']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

// ==================== PÁGINA 3: LOCALIDADE ====================

class OnboardingPage3 extends StatefulWidget {
  final int? selectedId;
  final Function(int, String, String) onNext;
  final VoidCallback onBack;

  const OnboardingPage3({
    super.key,
    required this.selectedId,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<OnboardingPage3> createState() => _OnboardingPage3State();
}

class _OnboardingPage3State extends State<OnboardingPage3> {
  List<dynamic> _localidades = [];
  bool _isLoading = true;
  int? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.selectedId;
    _carregarLocalidades();
  }

  Future<void> _carregarLocalidades() async {
    try {
      final url = Uri.parse('$apiBaseUrl/localidade');
      final response = await http.get(url);

      print('Localidades status: ${response.statusCode}');
      print('Localidades body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          _localidades = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar localidades: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Icon(Icons.location_on, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              Text(
                'Onde você atua?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),

        if (_isLoading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _localidades.length,
              itemBuilder: (context, index) {
                final loc = _localidades[index];
                return Card(
                  child: RadioListTile<int>(
                    title: Text(loc['cidade']),
                    subtitle: Text(loc['estado']),
                    value: loc['id'],
                    groupValue: _selectedId,
                    onChanged: (value) {
                      setState(() {
                        _selectedId = value;
                      });
                    },
                  ),
                );
              },
            ),
          ),

        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onBack,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 50),
                  ),
                  child: const Text('Voltar'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedId == null
                      ? null
                      : () {
                          final selected = _localidades.firstWhere(
                            (l) => l['id'] == _selectedId,
                          );
                          widget.onNext(
                            _selectedId!,
                            selected['cidade'],
                            selected['estado'],
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 50),
                  ),
                  child: const Text('Continuar'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==================== PÁGINA 4: USUÁRIO E SENHA ====================

class OnboardingPage4 extends StatefulWidget {
  final String initialUsuario;
  final String initialSenha;
  final Function(String, String) onNext;
  final VoidCallback onBack;

  const OnboardingPage4({
    super.key,
    required this.initialUsuario,
    required this.initialSenha,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<OnboardingPage4> createState() => _OnboardingPage4State();
}

class _OnboardingPage4State extends State<OnboardingPage4> {
  late TextEditingController _usuarioController;
  late TextEditingController _senhaController;
  late TextEditingController _confirmarSenhaController;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _usuarioController = TextEditingController(text: widget.initialUsuario);
    _senhaController = TextEditingController(text: widget.initialSenha);
    _confirmarSenhaController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.vpn_key, size: 80, color: Colors.blue),
          const SizedBox(height: 24),

          Text(
            'Crie suas credenciais de acesso',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          TextField(
            controller: _usuarioController,
            decoration: InputDecoration(
              labelText: 'Nome de usuário',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _senhaController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Senha',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _confirmarSenhaController,
            obscureText: _obscureConfirm,
            decoration: InputDecoration(
              labelText: 'Confirmar senha',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirm = !_obscureConfirm;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onBack,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 50),
                  ),
                  child: const Text('Voltar'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_usuarioController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Informe o nome de usuário'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (_senhaController.text.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'A senha deve ter no mínimo 6 caracteres',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (_senhaController.text !=
                        _confirmarSenhaController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('As senhas não coincidem'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    widget.onNext(
                      _usuarioController.text.trim(),
                      _senhaController.text,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 50),
                  ),
                  child: const Text('Continuar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }
}

// ==================== PÁGINA 5: CONFIRMAÇÃO ====================

class OnboardingPage5 extends StatelessWidget {
  final String nome;
  final String especialidade;
  final String localidade;
  final String usuario;
  final VoidCallback onConfirm;
  final VoidCallback onBack;

  const OnboardingPage5({
    super.key,
    required this.nome,
    required this.especialidade,
    required this.localidade,
    required this.usuario,
    required this.onConfirm,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.check_circle, size: 80, color: Colors.green),
          const SizedBox(height: 24),

          Text(
            'Confirme seus dados',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(Icons.person, 'Nome', nome),
                  const Divider(height: 24),
                  _buildInfoRow(
                    Icons.medical_services,
                    'Especialidade',
                    especialidade,
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(Icons.location_on, 'Localidade', localidade),
                  const Divider(height: 24),
                  _buildInfoRow(Icons.account_circle, 'Usuário', usuario),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 50),
                  ),
                  child: const Text('Voltar'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 50),
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Confirmar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
