import 'package:flutter/material.dart';
import 'package:segundoparcial/data/product_datasource.dart';
import 'package:segundoparcial/domain/products_notifier.dart';

class Formulario extends StatefulWidget {
  const Formulario({super.key});

  @override
  State<Formulario> createState() => _FormularioState();
}

class _FormularioState extends State<Formulario> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();

  double _rating = 3.0;
  bool _isAvailable = true;
  bool _submitted = false;
  bool _isSaving = false;
  DateTime? _selectedDate;
  final List<String> _tags = [];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _brandCtrl.dispose();
    _categoryCtrl.dispose();
    _stockCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  void _addTag() {
    final text = _tagCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _tags.add(text);
      _tagCtrl.clear();
    });
  }

  void _limpiarFormulario() {
    _formKey.currentState?.reset();
    _titleCtrl.clear();
    _descCtrl.clear();
    _priceCtrl.clear();
    _brandCtrl.clear();
    _categoryCtrl.clear();
    _stockCtrl.clear();
    setState(() {
      _tags.clear();
      _rating = 3.0;
      _isAvailable = true;
      _submitted = false;
      _selectedDate = null;
    });
  }

  Future<void> _guardarProducto() async {
    setState(() => _submitted = true);

    final formOk = _formKey.currentState?.validate() ?? false;
    if (!formOk || _selectedDate == null || _tags.isEmpty) return;

    setState(() => _isSaving = true);

    final messenger = ScaffoldMessenger.of(context);

    final productData = {
      "title": _titleCtrl.text.trim(),
      "description": _descCtrl.text.trim(),
      "price": double.parse(_priceCtrl.text),
      "brand": _brandCtrl.text.trim(),
      "category": _categoryCtrl.text.trim(),
      "stock": int.parse(_stockCtrl.text),
      "rating": _rating,
      "availabilityStatus": _isAvailable ? "In Stock" : "Out of Stock",
      "tags": List<String>.from(_tags),
      "meta": {"createdAt": _selectedDate!.toIso8601String()},
    };

    try {
      final newProduct = await ProductDatasource().createProduct(productData);
      ProductsNotifier.instance.addProduct(newProduct);

      messenger.showSnackBar(
        SnackBar(
          content: Text('✅ "${newProduct.title}" creado correctamente'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      _limpiarFormulario();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('❌ Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + topPadding),
        child: Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: AppBar(title: const Text('Nuevo producto')),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _sectionTitle('Datos del producto', colorScheme),
            const SizedBox(height: 12),
            _field(_titleCtrl, 'Título', validator: _req('título')),
            _field(
              _descCtrl,
              'Descripción',
              maxLines: 3,
              validator: _req('descripción'),
            ),
            Row(
              children: [
                Expanded(
                  child: _field(
                    _priceCtrl,
                    'Precio',
                    type: TextInputType.number,
                    validator: _priceVal,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(
                    _stockCtrl,
                    'Stock',
                    type: TextInputType.number,
                    validator: _stockVal,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: _field(_brandCtrl, 'Marca')),
                const SizedBox(width: 12),
                Expanded(child: _field(_categoryCtrl, 'Categoría')),
              ],
            ),
            const SizedBox(height: 4),
            _sectionTitle('Rating', colorScheme),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _rating,
                    min: 0,
                    max: 5,
                    divisions: 10,
                    label: _rating.toStringAsFixed(1),
                    onChanged: (v) => setState(() => _rating = v),
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            _sectionTitle('Disponibilidad', colorScheme),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: SwitchListTile(
                title: Text(_isAvailable ? 'En stock' : 'Sin stock'),
                subtitle: Text(
                  _isAvailable
                      ? 'El producto está disponible'
                      : 'El producto no está disponible',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                secondary: Icon(
                  _isAvailable
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                  color: _isAvailable ? Colors.green : Colors.red,
                ),
                value: _isAvailable,
                onChanged: (v) => setState(() => _isAvailable = v),
              ),
            ),
            const SizedBox(height: 4),
            _sectionTitle('Fecha de creación', colorScheme),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(Icons.calendar_month, color: colorScheme.primary),
                title: Text(
                  _selectedDate == null
                      ? 'Seleccionar fecha'
                      : _selectedDate!.toLocal().toString().split(' ')[0],
                  style: TextStyle(
                    color: _selectedDate == null
                        ? colorScheme.onSurfaceVariant
                        : null,
                  ),
                ),
                trailing: _selectedDate != null
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() => _selectedDate = null),
                      )
                    : null,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
            ),
            if (_submitted && _selectedDate == null)
              _errorText('La fecha es obligatoria'),
            const SizedBox(height: 8),
            _sectionTitle('Tags', colorScheme),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _tagCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Escribir tag',
                      prefixIcon: Icon(Icons.label_outline),
                    ),
                    onFieldSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _addTag,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            if (_tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _tags
                      .map(
                        (tag) => Chip(
                          label: Text(tag),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => setState(() => _tags.remove(tag)),
                        ),
                      )
                      .toList(),
                ),
              ),
            if (_submitted && _tags.isEmpty)
              _errorText('Debe agregar al menos un tag'),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _isSaving ? null : _guardarProducto,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Guardar producto',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, ColorScheme cs) => Text(
    text,
    style: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: cs.primary,
      letterSpacing: 0.5,
    ),
  );

  Widget _field(
    TextEditingController ctrl,
    String label, {
    int maxLines = 1,
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: ctrl,
      decoration: InputDecoration(labelText: label),
      maxLines: maxLines,
      keyboardType: type,
      validator: validator,
    ),
  );

  Widget _errorText(String msg) => Padding(
    padding: const EdgeInsets.only(left: 4, top: 2, bottom: 8),
    child: Text(msg, style: const TextStyle(color: Colors.red, fontSize: 12)),
  );

  String? Function(String?) _req(String campo) =>
      (v) =>
          (v == null || v.trim().isEmpty) ? 'El $campo es obligatorio' : null;

  String? _priceVal(String? v) {
    if (v == null || v.isEmpty) return 'Requerido';
    final n = double.tryParse(v);
    if (n == null) return 'Número inválido';
    if (n <= 0) return 'Debe ser > 0';
    return null;
  }

  String? _stockVal(String? v) {
    if (v == null || v.isEmpty) return 'Requerido';
    final n = int.tryParse(v);
    if (n == null) return 'Entero inválido';
    if (n < 0) return 'No negativo';
    return null;
  }
}
