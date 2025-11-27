-- Empresa / Administração
CREATE TABLE empresa (
    id                 BIGSERIAL PRIMARY KEY,
    nome               VARCHAR(150) NOT NULL,
    licenca_comercial  VARCHAR(100),
    telefone           VARCHAR(20),
    email              VARCHAR(150),
    endereco           VARCHAR(3000)
    logo_url           VARCHAR(255),
    created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- "Como conheceu"
CREATE TABLE como_conheceu (
    id          BIGSERIAL PRIMARY KEY,
    empresa_id  BIGINT NOT NULL REFERENCES empresa(id),
    descricao   VARCHAR(100) NOT NULL,
    ativo       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (empresa_id, descricao)
);

-- Serviços
CREATE TABLE servico (
    id              BIGSERIAL PRIMARY KEY,
    empresa_id      BIGINT NOT NULL REFERENCES empresa(id),
    nome            VARCHAR(150) NOT NULL,
    descricao       TEXT,
    duracao_base_min INTEGER NOT NULL DEFAULT 60,
    preco_base       NUMERIC(12,2) NOT NULL DEFAULT 0,
    ativo           BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (empresa_id, nome)
);

-- Clientes
CREATE TABLE cliente (
    id                  BIGSERIAL PRIMARY KEY,
    empresa_id          BIGINT NOT NULL REFERENCES empresa(id),
    nome                VARCHAR(150) NOT NULL,
    sexo                TEXT CHECK (sexo IN ('M', 'F', 'O')),
    data_nascimento     DATE,
    como_conheceu_id    BIGINT REFERENCES como_conheceu(id),
    telefone            VARCHAR(20),
    email               VARCHAR(150),
    saldo_credito       BIGINT NOT NULL DEFAULT 0,
    observacoes         TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (empresa_id, email)
);

-- Endereços de clientes
CREATE TABLE endereco (
    id               BIGSERIAL PRIMARY KEY,
    empresa_id       BIGINT NOT NULL REFERENCES empresa(id),
    cliente_id       BIGINT REFERENCES cliente(id),
    tipo             TEXT NOT NULL CHECK (tipo IN ('RESIDENCIAL', 'COMERCIAL', 'OUTRO')),
    logradouro       VARCHAR(150) NOT NULL,
    numero           VARCHAR(20),
    complemento      VARCHAR(100),
    bairro_comunidade VARCHAR(100),
    cidade_area      VARCHAR(100),
    emirado          VARCHAR(2),
    referencia       VARCHAR(200),
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_endereco_cliente ON endereco(cliente_id);

-- Funcionários
CREATE TABLE funcionario (
    id                   BIGSERIAL PRIMARY KEY,
    empresa_id           BIGINT NOT NULL REFERENCES empresa(id),
    nome                 VARCHAR(150) NOT NULL,
    sexo                 TEXT CHECK (sexo IN ('M', 'F', 'O')),
    tipo_funcionario     TEXT NOT NULL CHECK (tipo_funcionario IN ('TECNICO', 'ADMINISTRATIVO', 'AMBOS')),
    email                VARCHAR(150),
    elegivel_comissao    BOOLEAN NOT NULL DEFAULT FALSE,
    salario_fixo_mensal  NUMERIC(12,2) NOT NULL DEFAULT 0,
    ativo                BOOLEAN NOT NULL DEFAULT TRUE,
    created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (empresa_id, email)
);

-- Relação funcionário x serviço + % de comissão
CREATE TABLE funcionario_servico (
    funcionario_id      BIGINT NOT NULL REFERENCES funcionario(id),
    servico_id          BIGINT NOT NULL REFERENCES servico(id),
    duracao_base_min_func  INTEGER,
    preco_base_funcionario NUMERIC(12,2),
    comissao_percentual NUMERIC(5,2) NOT NULL DEFAULT 0,
    PRIMARY KEY (funcionario_id, servico_id)
);

-- Usuários do sistema (login)
CREATE TABLE usuario (
    id              BIGSERIAL PRIMARY KEY,
    empresa_id      BIGINT NOT NULL REFERENCES empresa(id),
    nome            VARCHAR(150) NOT NULL,
    email           VARCHAR(150) NOT NULL,
    senha_hash      TEXT NOT NULL,
    tipo_usuario    TEXT NOT NULL CHECK (tipo_usuario IN ('ADMIN', 'FUNCIONARIO', 'CLIENTE')),
    cliente_id      BIGINT REFERENCES cliente(id),
    funcionario_id  BIGINT REFERENCES funcionario(id),
    ativo           BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (empresa_id, email)
);

-- Permissões por módulo
CREATE TABLE usuario_modulo (
    usuario_id  BIGINT NOT NULL REFERENCES usuario(id) ON DELETE CASCADE,
    modulo      TEXT NOT NULL CHECK (modulo IN ('ADMINISTRACAO', 'CLIENTES', 'AGENDA', 'VENDAS', 'RELATORIOS', 'FINANCEIRO')),
    PRIMARY KEY (usuario_id, modulo)
);

-- Pacotes (modelo)
CREATE TABLE pacote (
    id                  BIGSERIAL PRIMARY KEY,
    empresa_id          BIGINT NOT NULL REFERENCES empresa(id),
    nome                VARCHAR(150) NOT NULL,
    descricao           TEXT,
    servico_id          BIGINT REFERENCES servico(id),
    quantidade_sessoes  INTEGER NOT NULL DEFAULT 1,
    valor_total         NUMERIC(12,2) NOT NULL DEFAULT 0,
    ativo               BOOLEAN NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (empresa_id, nome)
);

-- Pacote comprado pelo cliente
CREATE TABLE pacote_cliente (
    id                      BIGSERIAL PRIMARY KEY,
    empresa_id              BIGINT NOT NULL REFERENCES empresa(id),
    pacote_id               BIGINT REFERENCES pacote(id),
    cliente_id              BIGINT NOT NULL REFERENCES cliente(id),
    data_compra             DATE NOT NULL DEFAULT CURRENT_DATE,
    quantidade_contratada   INTEGER NOT NULL,
    quantidade_utilizada    INTEGER NOT NULL DEFAULT 0,
    valor_total             NUMERIC(12,2) NOT NULL,
    valor_utilizado         NUMERIC(12,2) NOT NULL DEFAULT 0,
    observacoes             TEXT,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_pacote_cliente_cliente ON pacote_cliente(cliente_id);

-- Venda recorrente / mensalidade
CREATE TABLE assinatura_mensal (
    id              BIGSERIAL PRIMARY KEY,
    empresa_id      BIGINT NOT NULL REFERENCES empresa(id),
    cliente_id      BIGINT NOT NULL REFERENCES cliente(id),
    descricao       VARCHAR(150) NOT NULL,
    valor_mensal    NUMERIC(12,2) NOT NULL,
    dia_cobranca    SMALLINT NOT NULL,
    data_inicio     DATE NOT NULL,
    data_fim        DATE,
    ativo           BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_assinatura_cliente ON assinatura_mensal(cliente_id);

-- Padrão de agendamento recorrente
CREATE TABLE agendamento_recorrente (
    id              BIGSERIAL PRIMARY KEY,
    empresa_id      BIGINT NOT NULL REFERENCES empresa(id),
    profissional_id BIGINT NOT NULL REFERENCES funcionario(id),
    cliente_id      BIGINT NOT NULL REFERENCES cliente(id),
    servico_id      BIGINT REFERENCES servico(id),
    dia_semana      SMALLINT NOT NULL, -- 0=domingo ... 6=sábado
    hora_inicio     TIME NOT NULL,
    duracao_minutos INTEGER NOT NULL DEFAULT 60,
    data_inicio     DATE NOT NULL,
    data_fim        DATE,
    local           TEXT NOT NULL CHECK (local IN ('EMPRESA', 'CLIENTE_RESIDENCIAL', 'CLIENTE_COMERCIAL', 'OUTRO')),
    endereco_id     BIGINT REFERENCES endereco(id),
    valor_cobrado   NUMERIC(12,2),
    ativo           BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Agenda
CREATE TABLE agendamento (
    id                       BIGSERIAL PRIMARY KEY,
    profissional_id          BIGINT NOT NULL REFERENCES funcionario(id),
    cliente_id               BIGINT NOT NULL REFERENCES cliente(id),
    servico_id               BIGINT REFERENCES servico(id),
    tipo                     TEXT NOT NULL CHECK (tipo IN ('AVULSO', 'PACOTE')),
    status                   TEXT NOT NULL CHECK (status IN ('AGENDADO', 'CONFIRMADO', 'CONCLUIDO', 'CANCELADO', 'NAO_COMPARECEU')),
    data_hora_inicio         TIMESTAMPTZ NOT NULL,
    agendamento_recorrente_id BIGINT REFERENCES agendamento_recorrente(id),
    assinatura_mensal_id     BIGINT REFERENCES assinatura_mensal(id),
    valor_cobrado            NUMERIC (12,2)
    comissao_percentual      NUMERIC(5,2),
    comissao_valor           NUMERIC(12,2),
    impacta_agenda           BOOLEAN NOT NULL DEFAULT TRUE,
    observacoes              TEXT,
    created_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at               TIMESTAMPTZ NOT NULL DEFAULT NOW()
    total_liquido           NUMERIC(12,2) NOT NULL DEFAULT 0,
    observacoes             TEXT
);
CREATE INDEX idx_agendamento_data ON agendamento(data_hora_inicio);
CREATE INDEX idx_agendamento_profissional ON agendamento(profissional_id);
CREATE INDEX idx_agendamento_cliente ON agendamento(cliente_id);

-- Vendas (cabeçalho)
CREATE TABLE venda (
    id                   BIGSERIAL PRIMARY KEY,
    empresa_id           BIGINT NOT NULL REFERENCES empresa(id),
    cliente_id           BIGINT NOT NULL REFERENCES cliente(id),
    tipo                 TEXT NOT NULL CHECK (tipo IN ('AVULSO', 'PACOTE', 'RECORRENTE', 'OUTRO')),
    data_venda           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    valor_total          NUMERIC(12,2) NOT NULL DEFAULT 0,
    pacote_cliente_id    BIGINT REFERENCES pacote_cliente(id),
    assinatura_mensal_id BIGINT REFERENCES assinatura_mensal(id),
    observacoes          TEXT,
    created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_venda_data ON venda(data_venda);
CREATE INDEX idx_venda_cliente ON venda(cliente_id);

-- Itens de venda
CREATE TABLE venda_item (
    id              BIGSERIAL PRIMARY KEY,
    venda_id        BIGINT NOT NULL REFERENCES venda(id) ON DELETE CASCADE,
    servico_id      BIGINT REFERENCES servico(id),
    agendamento_id  BIGINT REFERENCES agendamento(id),
    descricao       VARCHAR(150),
    quantidade      NUMERIC(12,2) NOT NULL DEFAULT 1,
    valor_unitario  NUMERIC(12,2) NOT NULL,
    valor_total     NUMERIC(12,2) NOT NULL
);

-- Despesas recorrentes (modelo)
CREATE TABLE despesa_recorrente (
    id              BIGSERIAL PRIMARY KEY,
    empresa_id      BIGINT NOT NULL REFERENCES empresa(id),
    descricao       VARCHAR(150) NOT NULL,
    categoria       TEXT NOT NULL CHECK (categoria IN ('SALARIO', 'ALUGUEL', 'AGUA', 'LUZ', 'INTERNET', 'MATERIAL', 'OUTROS')),
    valor_padrao    NUMERIC(12,2) NOT NULL,
    dia_vencimento  SMALLINT NOT NULL,
    data_inicio     DATE NOT NULL,
    data_fim        DATE,
    ativo           BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Lançamentos de despesas
CREATE TABLE despesa (
    id                      BIGSERIAL PRIMARY KEY,
    empresa_id              BIGINT NOT NULL REFERENCES empresa(id),
    despesa_recorrente_id   BIGINT REFERENCES despesa_recorrente(id),
    descricao               VARCHAR(150) NOT NULL,
    categoria               TEXT NOT NULL CHECK (categoria IN ('SALARIO', 'ALUGUEL', 'AGUA', 'LUZ', 'INTERNET', 'MATERIAL', 'OUTROS')),
    tipo                    TEXT NOT NULL CHECK (tipo IN ('AVULSA', 'RECORRENTE')),
    valor                   NUMERIC(12,2) NOT NULL,
    data_competencia        DATE NOT NULL,
    data_vencimento         DATE,
    data_pagamento          DATE,
    pago                    BOOLEAN NOT NULL DEFAULT FALSE,
    observacoes             TEXT,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_despesa_data_competencia ON despesa(data_competencia);


CREATE INDEX idx_folha_profissional ON folha_pagamento_profissional(funcionario_id);