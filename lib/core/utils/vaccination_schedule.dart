class VaccinationSchedule {
  static List<Map<String, String>> getIndianSchedule() {
    return [
      {
        'name': 'BCG',
        'age': 'At birth',
        'description': 'Bacillus Calmette-Guérin (Tuberculosis)',
      },
      {
        'name': 'Hepatitis B - 1st Dose',
        'age': 'At birth',
        'description': 'Hepatitis B vaccine',
      },
      {
        'name': 'OPV - 0',
        'age': 'At birth',
        'description': 'Oral Polio Vaccine',
      },
      {
        'name': 'OPV - 1, DPT - 1, Hepatitis B - 2nd Dose',
        'age': '6 weeks',
        'description': 'Polio, Diphtheria, Pertussis, Tetanus, Hepatitis B',
      },
      {
        'name': 'OPV - 2, DPT - 2, Hepatitis B - 3rd Dose',
        'age': '10 weeks',
        'description': 'Polio, Diphtheria, Pertussis, Tetanus, Hepatitis B',
      },
      {
        'name': 'OPV - 3, DPT - 3, Hepatitis B - 4th Dose',
        'age': '14 weeks',
        'description': 'Polio, Diphtheria, Pertussis, Tetanus, Hepatitis B',
      },
      {
        'name': 'Measles - 1st Dose',
        'age': '9 months',
        'description': 'Measles vaccine',
      },
      {
        'name': 'MMR - 1st Dose',
        'age': '12 months',
        'description': 'Measles, Mumps, Rubella',
      },
      {
        'name': 'DPT Booster - 1',
        'age': '16-18 months',
        'description': 'Diphtheria, Pertussis, Tetanus booster',
      },
      {
        'name': 'OPV Booster',
        'age': '16-18 months',
        'description': 'Oral Polio Vaccine booster',
      },
      {
        'name': 'MMR - 2nd Dose',
        'age': '4-6 years',
        'description': 'Measles, Mumps, Rubella',
      },
      {
        'name': 'DPT Booster - 2',
        'age': '4-6 years',
        'description': 'Diphtheria, Pertussis, Tetanus booster',
      },
      {
        'name': 'TT',
        'age': '10 years',
        'description': 'Tetanus Toxoid',
      },
      {
        'name': 'TT',
        'age': '16 years',
        'description': 'Tetanus Toxoid',
      },
    ];
  }
}
