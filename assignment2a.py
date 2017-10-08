# Below I define a recursive function to make a list of all possible nucleotide
# combinations for an arbitrary length. (c.f. chapter 2 in Advanced Python For
# Biologists by Martin Jones (2014)).

def make_nucleotide_combos(length):
    if length == 1:
        return ['A', 'T', 'G', 'C']
    else:
        combos = []
        for sequence in make_nucleotide_combos(length -1):
            for base in ['A', 'T', 'G', 'C']:
                combos.append(sequence + base)
        return combos

# Place the 'assignment2a.txt' file in your working directory and read in the
# DNA sequence

with open('assignment2a.txt') as sequence_file:
    sequence_lines = sequence_file.readlines()[1:]

sequence = ""
for seq in sequence_lines:
    sequence = sequence + seq.replace("\n", "")

# Plce the 'codons.csv' file in the working directory and read it in to make a
# dictionary of codons and maching amino acids.

# Assuming that the first nucleotide is the first in a sequence of
# dinucleotides [1,2], [3,4], [5,6], etc., here I get the dinucleotides.

def split_nucleotides(sequence, length):
    return [sequence[i:i+length] for i in range(0, len(sequence), length)]

dinucleotides = split_nucleotides(sequence = sequence, length = 2)

# The frequencies of dinucleotides are:

for dinucleotide in make_nucleotide_combos(2):
    total = []
    for i in dinucleotides:
        total.append(i == dinucleotide)
    print("There are " + str(sum(total)) + " " + dinucleotide + "s")

# If the beginning of the sequence starts the frame for codons, then the
# frequencies of codons are

codons = split_nucleotides(sequence = sequence, length = 3)

for codon in make_nucleotide_combos(3):
    total = []
    for i in codons:
        total.append(i == codon)
    print("There are " + str(sum(total)) + " " + codon + "s")

# Place the 'codons.csv' file in your working directory and read it in to make a
# dictionary of codons and maching amino acids.

with open('codons.csv') as codon_file:
    codon_lines = codon_file.readlines()[1:]

codon_dict = {}
for line in codon_lines:
    line = line.split(",")
    codon_dict[line[2].replace("\n", "")] =  line[1]

# Translate the DNA sequence to proteins.

codons = split_nucleotides(sequence = sequence, length = 3)

# The amino acid sequence is:

print("The amino acid sequence is")
protein_sequence = ""
for codon in codons:
    if len(codon) == 3:
        protein_sequence = protein_sequence + codon_dict[codon]

print(protein_sequence)