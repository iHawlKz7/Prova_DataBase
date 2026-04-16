-- =========================================
-- SIGAEDU - SCRIPT COMPLETO
-- PostgreSQL
-- =========================================

DROP SCHEMA IF EXISTS academico CASCADE;
DROP SCHEMA IF EXISTS seguranca CASCADE;

CREATE SCHEMA seguranca;
CREATE SCHEMA academico;

-- =========================================
-- TABELAS DE SEGURANÇA
-- =========================================
CREATE TABLE seguranca.usuario (
    id_usuario BIGSERIAL PRIMARY KEY,
    nome_usuario VARCHAR(150) NOT NULL,
    email_usuario VARCHAR(150) NOT NULL UNIQUE,
    endereco_usuario VARCHAR(150) NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE
);

-- =========================================
-- TABELAS ACADÊMICAS
-- =========================================
CREATE TABLE academico.operador_pedagogico (
    matricula_operador_pedagogico VARCHAR(20) PRIMARY KEY,
    ativo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE academico.aluno (
    id_aluno BIGSERIAL PRIMARY KEY,
    ra_aluno BIGINT NOT NULL UNIQUE,
    data_ingresso DATE NOT NULL,
    id_usuario BIGINT NOT NULL UNIQUE,
    matricula_operador_pedagogico VARCHAR(20) NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_aluno_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES seguranca.usuario(id_usuario),
    CONSTRAINT fk_aluno_operador
        FOREIGN KEY (matricula_operador_pedagogico)
        REFERENCES academico.operador_pedagogico(matricula_operador_pedagogico)
);

CREATE TABLE academico.docente (
    id_docente BIGSERIAL PRIMARY KEY,
    nome_docente VARCHAR(150) NOT NULL UNIQUE,
    ativo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE academico.disciplina (
    id_disciplina BIGSERIAL PRIMARY KEY,
    cod_servico_academico VARCHAR(20) NOT NULL UNIQUE,
    nome_disciplina VARCHAR(150) NOT NULL,
    carga_h INT NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE academico.turma (
    id_turma BIGSERIAL PRIMARY KEY,
    id_disciplina BIGINT NOT NULL,
    id_docente BIGINT NOT NULL,
    ciclo_calendario VARCHAR(10) NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_turma_disciplina
        FOREIGN KEY (id_disciplina)
        REFERENCES academico.disciplina(id_disciplina),
    CONSTRAINT fk_turma_docente
        FOREIGN KEY (id_docente)
        REFERENCES academico.docente(id_docente),
    CONSTRAINT uq_turma UNIQUE (id_disciplina, id_docente, ciclo_calendario)
);

CREATE TABLE academico.matricula (
    id_matricula BIGSERIAL PRIMARY KEY,
    id_aluno BIGINT NOT NULL,
    id_turma BIGINT NOT NULL,
    score_final NUMERIC(4,2) NOT NULL CHECK (score_final >= 0 AND score_final <= 10),
    situacao VARCHAR(20) NOT NULL DEFAULT 'ATIVA'
        CHECK (situacao IN ('ATIVA', 'TRANCADA', 'CANCELADA', 'CONCLUIDA')),
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_matricula_aluno
        FOREIGN KEY (id_aluno)
        REFERENCES academico.aluno(id_aluno),
    CONSTRAINT fk_matricula_turma
        FOREIGN KEY (id_turma)
        REFERENCES academico.turma(id_turma),
    CONSTRAINT uq_matricula UNIQUE (id_aluno, id_turma)
);

-- =========================================
-- DCL - ROLES E PERMISSÕES
-- =========================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'professor_role') THEN
        CREATE ROLE professor_role;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'coordenador_role') THEN
        CREATE ROLE coordenador_role;
    END IF;
END
$$;

GRANT USAGE ON SCHEMA academico TO professor_role;
GRANT USAGE ON SCHEMA seguranca TO professor_role;
GRANT USAGE ON SCHEMA academico TO coordenador_role;
GRANT USAGE ON SCHEMA seguranca TO coordenador_role;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA academico TO coordenador_role;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA seguranca TO coordenador_role;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA academico TO coordenador_role;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA seguranca TO coordenador_role;

GRANT SELECT ON academico.docente TO professor_role;
GRANT SELECT ON academico.disciplina TO professor_role;
GRANT SELECT ON academico.turma TO professor_role;
GRANT SELECT (id_matricula, id_aluno, id_turma, score_final, situacao, ativo)
ON academico.matricula TO professor_role;
GRANT UPDATE (score_final) ON academico.matricula TO professor_role;

GRANT SELECT (id_usuario, nome_usuario, ativo)
ON seguranca.usuario TO professor_role;

-- =========================================
-- CARGA DE DADOS
-- =========================================

INSERT INTO seguranca.usuario (nome_usuario, email_usuario, endereco_usuario) VALUES
('Ana Beatriz Lima', 'ana.lima@aluno.edu.br', 'Braganca Paulista/SP'),
('Bruno Henrique Souza', 'bruno.souza@aluno.edu.br', 'Atibaia/SP'),
('Camila Ferreira', 'camila.ferreira@aluno.edu.br', 'Jundiai/SP'),
('Diego Martins', 'diego.martins@aluno.edu.br', 'Campinas/SP'),
('Eduarda Nunes', 'eduarda.nunes@aluno.edu.br', 'Itatiba/SP'),
('Felipe Araujo', 'felipe.araujo@aluno.edu.br', 'Louveira/SP'),
('Gabriela Torres', 'gabriela.torres@aluno.edu.br', 'Nazare Paulista/SP'),
('Helena Rocha', 'helena.rocha@aluno.edu.br', 'Piracaia/SP'),
('Igor Santana', 'igor.santana@aluno.edu.br', 'Jarinu/SP');

INSERT INTO academico.operador_pedagogico (matricula_operador_pedagogico) VALUES
('OP8999'),
('OP9000'),
('OP9001'),
('OP9002'),
('OP9003'),
('OP9004');

INSERT INTO academico.aluno (ra_aluno, data_ingresso, id_usuario, matricula_operador_pedagogico) VALUES
(2026001, '2026-01-20', 1, 'OP9001'),
(2026002, '2026-01-21', 2, 'OP9002'),
(2026003, '2026-01-22', 3, 'OP9001'),
(2026004, '2026-01-23', 4, 'OP9003'),
(2026005, '2026-01-24', 5, 'OP9002'),
(2026006, '2026-01-25', 6, 'OP9004'),
(2025010, '2025-08-05', 7, 'OP8999'),
(2025011, '2025-08-06', 8, 'OP8999'),
(2025012, '2025-08-07', 9, 'OP9000');

INSERT INTO academico.docente (nome_docente) VALUES
('Prof. Carlos Mendes'),
('Profa. Juliana Castro'),
('Prof. Eduardo Pires'),
('Prof. Renato Alves'),
('Profa. Marina Lopes'),
('Prof. Ricardo Faria');

INSERT INTO academico.disciplina (cod_servico_academico, nome_disciplina, carga_h) VALUES
('ADS101', 'Banco de Dados', 80),
('ADS102', 'Engenharia de Software', 80),
('ADS103', 'Algoritmos', 60),
('ADS104', 'Redes de Computadores', 60),
('ADS105', 'Sistemas Operacionais', 60),
('ADS106', 'Estruturas de Dados', 80);

INSERT INTO academico.turma (id_disciplina, id_docente, ciclo_calendario) VALUES
(1, 1, '2026/1'),
(2, 2, '2026/1'),
(3, 4, '2026/1'),
(4, 5, '2026/1'),
(5, 3, '2026/1'),
(6, 6, '2026/1'),
(1, 1, '2025/2'),
(2, 2, '2025/2'),
(3, 4, '2025/2'),
(4, 5, '2025/2'),
(5, 3, '2025/2'),
(6, 6, '2025/2');

INSERT INTO academico.matricula (id_aluno, id_turma, score_final, situacao) VALUES
(1, 1, 9.1, 'ATIVA'),
(1, 2, 8.4, 'ATIVA'),
(1, 5, 8.9, 'ATIVA'),
(2, 1, 7.3, 'ATIVA'),
(2, 3, 6.8, 'ATIVA'),
(2, 4, 7.0, 'ATIVA'),
(3, 1, 5.9, 'ATIVA'),
(3, 2, 7.5, 'ATIVA'),
(3, 6, 6.1, 'ATIVA'),
(4, 3, 4.7, 'ATIVA'),
(4, 4, 6.2, 'ATIVA'),
(4, 5, 5.8, 'ATIVA'),
(5, 2, 9.5, 'ATIVA'),
(5, 4, 8.1, 'ATIVA'),
(5, 6, 8.7, 'ATIVA'),
(6, 1, 6.4, 'ATIVA'),
(6, 3, 5.6, 'ATIVA'),
(6, 5, 6.9, 'ATIVA'),
(7, 7, 6.4, 'CONCLUIDA'),
(7, 8, 7.1, 'CONCLUIDA'),
(8, 9, 8.8, 'CONCLUIDA'),
(8, 10, 7.9, 'CONCLUIDA'),
(9, 11, 5.5, 'CONCLUIDA'),
(9, 12, 6.3, 'CONCLUIDA');

-- =========================================
-- SOFT DELETE - EXEMPLOS
-- =========================================
-- UPDATE academico.aluno
-- SET ativo = FALSE
-- WHERE id_aluno = 1;

-- UPDATE academico.matricula
-- SET ativo = FALSE, situacao = 'CANCELADA'
-- WHERE id_matricula = 1;

-- =========================================
-- QUERIES SOLICITADAS
-- =========================================

-- 1. Listagem de Matriculados
SELECT
    u.nome_usuario AS nome_aluno,
    d.nome_disciplina,
    t.ciclo_calendario
FROM academico.matricula m
JOIN academico.aluno a
    ON a.id_aluno = m.id_aluno
JOIN seguranca.usuario u
    ON u.id_usuario = a.id_usuario
JOIN academico.turma t
    ON t.id_turma = m.id_turma
JOIN academico.disciplina d
    ON d.id_disciplina = t.id_disciplina
WHERE t.ciclo_calendario = '2026/1'
  AND m.ativo = TRUE
  AND a.ativo = TRUE
  AND u.ativo = TRUE
  AND t.ativo = TRUE
  AND d.ativo = TRUE
ORDER BY u.nome_usuario, d.nome_disciplina;

-- 2. Baixo Desempenho
-- Observação:
-- Com os dados fornecidos, nenhuma disciplina possui média inferior a 6.0,
-- portanto esta consulta pode retornar 0 linhas.
SELECT
    d.nome_disciplina,
    ROUND(AVG(m.score_final), 2) AS media_notas
FROM academico.matricula m
JOIN academico.turma t
    ON t.id_turma = m.id_turma
JOIN academico.disciplina d
    ON d.id_disciplina = t.id_disciplina
WHERE m.ativo = TRUE
  AND t.ativo = TRUE
  AND d.ativo = TRUE
GROUP BY d.nome_disciplina
HAVING AVG(m.score_final) < 6.0
ORDER BY media_notas ASC, d.nome_disciplina;

-- 3. Alocação de Docentes
SELECT
    doc.nome_docente,
    dis.nome_disciplina
FROM academico.docente doc
LEFT JOIN academico.turma t
    ON t.id_docente = doc.id_docente
   AND t.ativo = TRUE
LEFT JOIN academico.disciplina dis
    ON dis.id_disciplina = t.id_disciplina
   AND dis.ativo = TRUE
WHERE doc.ativo = TRUE
ORDER BY doc.nome_docente, dis.nome_disciplina;

-- 4. Destaque Acadêmico
SELECT
    u.nome_usuario AS nome_aluno,
    m.score_final
FROM academico.matricula m
JOIN academico.aluno a
    ON a.id_aluno = m.id_aluno
JOIN seguranca.usuario u
    ON u.id_usuario = a.id_usuario
JOIN academico.turma t
    ON t.id_turma = m.id_turma
JOIN academico.disciplina d
    ON d.id_disciplina = t.id_disciplina
WHERE d.nome_disciplina = 'Banco de Dados'
  AND m.score_final = (
      SELECT MAX(m2.score_final)
      FROM academico.matricula m2
      JOIN academico.turma t2
          ON t2.id_turma = m2.id_turma
      JOIN academico.disciplina d2
          ON d2.id_disciplina = t2.id_disciplina
      WHERE d2.nome_disciplina = 'Banco de Dados'
  );