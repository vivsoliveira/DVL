# DVL - Data Visualization Language

**DVL** é uma linguagem de programação de alto nível voltada para **análise de dados temporais** e **monitoramento de sensores ambientais** (como vento, chuva, luz e temperatura).
Inspirada em **R** e em linguagens funcionais de análise, a DVL foi projetada para ser **didática**, **enxuta** e **fácil de aprender**, servindo como uma plataforma para experimentação de conceitos de compiladores e análise de dados em tempo real.

Além de trabalhar com coleções e estatísticas básicas, a DVL incorpora recursos para manipulação de **fluxos de tempo** e **leituras contínuas de sensores**, mapeando variáveis diretamente para **registradores**, o que permite cálculos e simulações temporais com alto desempenho.

---

## Características Principais

* **Declarações explícitas** com `decl val` (imutável) ou `decl var` (mutável).
* **Declarações temporais e ambientais**:

  * `reg` — registradores de alta performance para dados que mudam ao longo do tempo (ex.: tempo, acumuladores, índices).
  * `sensor` — variáveis somente leitura que representam entradas externas da VM (ex.: vento, chuva, luz, temperatura).
* **Tipos opcionais**: `int`, `float`, `bool`, `string`, `lista`.
* **Delimitação de instruções** com `;` (ponto e vírgula), mantendo legibilidade.
* **Condicionais** (`se` / `senao`) e **laços temporais** (`enquanto`).
* **Entrada e saída** intuitivas:

  * `ler()` → lê um valor do usuário.
  * `mostrar()` → exibe valores ou medições em tempo real.
* **Coleções e datasets**:

  * Listas: `[1, 2, 3]`.
  * Datasets tabulares:

    ```dvl
    dataset "leituras" { tempo: [0,10,20], chuva: [0.0, 2.3, 0.0] };
    ```

    Acesso direto a colunas: `leituras.chuva`.
* **Funções estatísticas nativas** prefixadas por `#`:

  * `#soma(lista)`
  * `#media(lista)`
  * `#minimo(lista)`
  * `#maximo(lista)`
* **Encadeamento de operações** com o operador de pipeline `->>`:

  ```dvl
  leituras.chuva ->> #media ;
  ```
* **Definição de funções** com `funcao nome(parametros) { ... }`.
* **Retorno de valores** com `retorna valor ;`.
* **Comentários**:

  * Linha única: `# exemplo` ou `// exemplo`.
  * Bloco: `/* exemplo */`.

---

## Estruturas Temporais e Sensores

O DVL foi estendido para lidar com **dados que variam ao longo do tempo**, permitindo modelar situações reais de coleta contínua:

### Registradores (`reg`)

Registradores são variáveis armazenadas diretamente em registradores da VM, ideais para contadores, acumuladores e estados temporais.

```dvl
reg var tempo : int := 0 ;
reg var chuva_acumulada : float := 0.0 ;
```

* `reg var` → registrador mutável.
* `reg val` → registrador imutável.
* Usados para cálculos rápidos em loops temporais (`enquanto`).

### Sensores (`sensor`)

Sensores representam valores externos fornecidos pela VM ou ambiente.
São somente leitura e usados para capturar medidas como vento, luz ou chuva.

```dvl
sensor vento : int ;
sensor chuva : float ;
sensor luz   : int ;
sensor temp  : float ;
```

Podem ser usados diretamente em expressões:

```dvl
se (vento > 80) {
  mostrar("Vento forte detectado") ;
}
```

---

## Exemplo de Código

Os arquivos de exemplo mostram casos práticos de análise temporal:

* [`exemplo_simplificado.dvl`](./exemplo_simplificado.dvl):
  simulação minuto a minuto, acumulando chuva e exibindo alertas de vento e luminosidade.

* [`exemplo_avancado.dvl`](./exemplo_avancado.dvl):
  análise de datasets históricos e agregações temporais com janelas de 10 minutos.

---

## Gramática (EBNF)

A gramática completa encontra-se em [`gramatica.ebnf`](./gramatica.ebnf), incluindo:

```
registrador_decl ::= "reg" ( "val" | "var" ) identificador [ ":" tipo ] ":=" expressao ";" ;
sensor_decl      ::= "sensor" identificador ":" tipo ";" ;
```

---

## Diferenciais

O DVL não busca competir com linguagens como Python, R ou C, mas oferecer uma alternativa **didática e contextualizada** para **análise de dados temporais** e **simulação de sensores** em ambientes acadêmicos.

**Principais diferenciais:**

* Sintaxe totalmente em português, legível e autoexplicativa.
* Recursos nativos para variáveis temporais (`reg`) e sensores (`sensor`).
* Operações estatísticas integradas e expressivas (`#media`, `#soma`, etc.).
* Pipeline de dados (`->>`) para composição e análise de fluxos.
* Estrutura ideal para ensino de compiladores e linguagens com VM.

---

## Em resumo

O **DVL** é uma linguagem criada para **analisar, simular e compreender comportamentos temporais e ambientais**, oferecendo uma abordagem **didática**, **estatística** e **temporal** dentro de um ecossistema próprio de compilação e execução.

Seu objetivo é unir a clareza de linguagens educacionais à praticidade da análise de dados moderna — com foco em **tempo, sensores e variáveis de estado**.
