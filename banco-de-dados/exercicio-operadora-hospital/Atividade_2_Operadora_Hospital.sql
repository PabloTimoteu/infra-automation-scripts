CREATE TABLE Operadoras (
	CodigoOP INT PRIMARY KEY,
	Nome VARCHAR (100)
);
CREATE TABLE Hospital (
	CodigoH INT PRIMARY KEY,
	Nome VARCHAR (100)
);

CREATE TABLE Contrato (
	CodigoOP INT,
	CodigoH INT,
	Data_Inicio DATE,
	Data_Fim DATE,

	PRIMARY KEY (CodigoOP, CodigoH, Data_Inicio),

	FOREIGN KEY (CodigoOP)
		REFERENCES Operadoras (CodigoOP),

	FOREIGN KEY (CodigoH)
		REFERENCES Hospital(CodigoH)
);

INSERT INTO Operadoras
VALUES
(1, 'Unimed'),
(2, 'Bradesco Saúde');

INSERT INTO Hospital
VALUES
(1, 'Hospital Gavaza'),
(2, 'Hospital N. S. Dores');

INSERT INTO Contrato
VALUES
(1,1, '2025-01-01', NULL),
(2,2, '2025-02-01', '2025-12-31');

SELECT * FROM Operadoras;

SELECT
	o.Nome,
	h.Nome,
	c.Data_inicio,
	c.Data_Fim
FROM Contrato c
JOIN Operadoras o
	ON c.CodigoOP = o.CodigoOP
JOIN Hospital h
	ON c.CodigoH = h.codigoH;
	



