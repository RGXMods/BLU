# Claude Code Router - BLU Addon Agents

This directory contains specialized AI agent configurations for the BLU (Better Level-Up!) World of Warcraft addon project.

## Available Agents

### 1. wow-ui-expert (GPT-4)
**Expertise**: WoW addon UI/UX design and implementation
- WoW API and Interface system
- UI design patterns and best practices  
- User experience optimization
- Performance-oriented interface design
- Cross-resolution compatibility

**Use for**: Options panels, UI layouts, interface design, WoW-specific UI patterns

### 2. lua-optimizer (Deepseek)
**Expertise**: Lua performance optimization and efficiency
- Memory management and garbage collection
- Algorithm efficiency and data structures
- Event system optimization
- Module loading and dependency management
- Performance profiling and measurement

**Use for**: Code optimization, performance improvements, memory usage reduction

### 3. code-reviewer (Gemini)
**Expertise**: Code quality, security, and best practices
- Code architecture and design patterns
- Security considerations for WoW addons
- Error handling and edge case management
- Testing strategies and quality assurance
- Maintainability and extensibility

**Use for**: Code reviews, bug identification, architectural guidance

## Configuration

Each agent is configured with:
- Specific API keys for different providers
- Tailored system prompts for WoW addon development
- Temperature and token limits optimized for their role
- Trigger words for automatic routing

## API Keys Required

Set these environment variables:
- `OPENROUTER_API_KEY`: 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
- `DEEPSEEK_API_KEY`: sk-9d40a3da25cc4a29b59accba47bef9bf  
- `GEMINI_API_KEY`: AIzaSyCB3Zi4UgMZcOEDJp-VgYJtu2WNL7i7QC0

## Usage Examples

```bash
# Automatically routed based on keywords
claude-code-router "Optimize the sound loading performance"  # → lua-optimizer
claude-code-router "Review this UI panel code for bugs"     # → code-reviewer  
claude-code-router "Design a better options interface"      # → wow-ui-expert

# Explicitly specify agent
claude-code-router --agent wow-ui-expert "Help with frame positioning"
claude-code-router --agent lua-optimizer "Reduce memory usage in registry"
claude-code-router --agent code-reviewer "Check this module for issues"
```

## Project Context

All agents understand the BLU addon's:
- Modular architecture without external dependencies
- Custom framework implementation
- v6.0.0-alpha development status
- Event-driven design patterns
- Performance optimization requirements