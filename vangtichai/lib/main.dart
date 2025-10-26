import 'package:flutter/material.dart';
import 'change_calculator.dart';

void main() {
  runApp(const VangTichaiApp());
}

class VangTichaiApp extends StatelessWidget {
  const VangTichaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VangTiChai',
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF2C2C2C),
          primary: Color(0xFFB39CD0),
          secondary: Color(0xFFA8DADC),
          tertiary: Color(0xFFFFC1CC),
          onSurface: Color(0xFFE4E4E4),
          onPrimary: Color(0xFF2C2C2C),
        ),
        scaffoldBackgroundColor: const Color(0xFF2C2C2C),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const ChangeCalculatorScreen(),
    );
  }
}

class ChangeCalculatorScreen extends StatefulWidget {
  const ChangeCalculatorScreen({super.key});

  @override
  State<ChangeCalculatorScreen> createState() => _ChangeCalculatorScreenState();
}

class _ChangeCalculatorScreenState extends State<ChangeCalculatorScreen> {
  String _currentAmount = '0';
  Map<int, int> _changeBreakdown = {};

  @override
  void initState() {
    super.initState();
    _updateChange();
  }

  void _onNumberPressed(String number) {
    setState(() {
      if (_currentAmount == '0') {
        _currentAmount = number;
      } else {
        _currentAmount += number;
      }
      _updateChange();
    });
  }

  void _onClearPressed() {
    setState(() {
      _currentAmount = '0';
      _updateChange();
    });
  }

  void _updateChange() {
    int amount = int.tryParse(_currentAmount) ?? 0;
    _changeBreakdown = ChangeCalculator.calculateChange(amount);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            if (orientation == Orientation.portrait) {
              return _buildPortraitLayout();
            } else {
              return _buildLandscapeLayout();
            }
          },
        ),
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return Column(
      children: [
        //  Amount Display
        Container(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
          child: _buildAmountDisplay(),
        ),
        // Main
        Expanded(
          child: Row(
            children: [
              // Left side - Change list
              Expanded(
                flex: 4,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: _buildChangeListSingleColumn(),
                    ),
                  ),
                ),
              ),
              // Right side
              Expanded(
                flex: 8,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: _buildNumericKeypad(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        // Left side
        Expanded(
          flex: 5,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: _buildAmountDisplay(),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _buildChangeListTwoColumns(),
                ),
              ),
            ],
          ),
        ),
        // Right side
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.all(4),
            child: _buildNumericKeypad(),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountDisplay() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Taka:',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.secondary,
            ),
          ),
          Expanded(
            child: Text(
              ChangeCalculator.formatAmount(int.parse(_currentAmount)),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeListSingleColumn() {
    return ListView.builder(
      itemCount: ChangeCalculator.denominations.length,
      itemBuilder: (context, index) {
        int denomination = ChangeCalculator.denominations[index];
        int count = _changeBreakdown[denomination] ?? 0;
        return _buildChangeItem(denomination, count);
      },
    );
  }

  Widget _buildChangeListTwoColumns() {
    final denominations = ChangeCalculator.denominations;
    final halfLength = (denominations.length / 2).ceil();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // First column
        Expanded(
          child: ListView.builder(
            itemCount: halfLength,
            itemBuilder: (context, index) {
              int denomination = denominations[index];
              int count = _changeBreakdown[denomination] ?? 0;
              return _buildChangeItem(denomination, count);
            },
          ),
        ),
        const SizedBox(width: 4),
        // Second column
        Expanded(
          child: ListView.builder(
            itemCount: denominations.length - halfLength,
            itemBuilder: (context, index) {
              int denomination = denominations[index + halfLength];
              int count = _changeBreakdown[denomination] ?? 0;
              return _buildChangeItem(denomination, count);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChangeItem(int denomination, int count) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: count > 0 ? colorScheme.secondary : const Color(0xFF505050),
          width: 2,
        ),
        boxShadow: count > 0
            ? [
                BoxShadow(
                  color: colorScheme.secondary.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            style: TextStyle(
              fontSize: 18,
              fontWeight: count > 0 ? FontWeight.bold : FontWeight.normal,
              color: count > 0 ? colorScheme.secondary : colorScheme.onSurface,
            ),
            child: Text('$denomination:'),
          ),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            style: TextStyle(
              fontSize: 18,
              fontWeight: count > 0 ? FontWeight.bold : FontWeight.normal,
              color: count > 0
                  ? colorScheme.secondary
                  : const Color(0xFFAAAAAA),
            ),
            child: Text('$count'),
          ),
        ],
      ),
    );
  }

  Widget _buildNumericKeypad() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isPortrait =
            MediaQuery.of(context).orientation == Orientation.portrait;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: isPortrait ? constraints.maxHeight * 0.015 : 1),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildKeypadRow(['1', '2', '3'], isPortrait),
                  SizedBox(height: isPortrait ? 12 : 8.5),
                  _buildKeypadRow(['4', '5', '6'], isPortrait),
                  SizedBox(height: isPortrait ? 12 : 8.5),
                  _buildKeypadRow(['7', '8', '9'], isPortrait),
                  SizedBox(height: isPortrait ? 12 : 8.5),
                  _buildKeypadRow(['0', 'C'], isPortrait),
                ],
              ),
            ),
            SizedBox(height: isPortrait ? constraints.maxHeight * 0.15 : 1),
          ],
        );
      },
    );
  }

  Widget _buildKeypadRow(List<String> buttons, bool isPortrait) {
    // last row with 0 and C
    bool isLastRow =
        buttons.length == 2 && buttons.contains('0') && buttons.contains('C');

    if (isLastRow) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isPortrait ? 5.0 : 3.0),
              child: _buildKeypadButton('0', isPortrait),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isPortrait ? 5.0 : 3.0),
              child: _buildKeypadButton('C', isPortrait),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buttons.map((button) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isPortrait ? 5.0 : 3.0),
            child: _buildKeypadButton(button, isPortrait),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKeypadButton(String label, bool isPortrait) {
    final bool isClear = label == 'C';
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (isClear) {
          // C button
          double height = isPortrait ? 60.0 : 62.0;
          if (constraints.maxHeight < height) {
            height = constraints.maxHeight * 0.9;
          }

          return Center(
            child: _AnimatedButton(
              onPressed: _onClearPressed,
              child: SizedBox(
                height: height,
                child: ElevatedButton(
                  onPressed: _onClearPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.tertiary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    padding: EdgeInsets.zero,
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: isPortrait ? 24 : 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          // Number buttons
          double size = isPortrait
              ? constraints.maxWidth.clamp(50.0, 70.0)
              : constraints.maxWidth.clamp(55.0, 75.0);

          if (constraints.maxHeight < size) {
            size = constraints.maxHeight * 0.9;
          }

          return Center(
            child: _AnimatedButton(
              onPressed: () => _onNumberPressed(label),
              child: SizedBox(
                width: size,
                height: size,
                child: ElevatedButton(
                  onPressed: () => _onNumberPressed(label),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: const CircleBorder(),
                    elevation: 4,
                    padding: EdgeInsets.zero,
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: isPortrait ? 24 : 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;

  const _AnimatedButton({required this.child, required this.onPressed});

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}
