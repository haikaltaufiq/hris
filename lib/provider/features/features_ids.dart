class FeatureIds {
  // ====================== Fitur Cuti ======================
  static const approveCuti = "approve_cuti";
  static const declineCuti = "decline_cuti";
  static const deleteCuti = "delete_cuti";
  static const editCuti = "edit_cuti";
  static const userDeleteCuti = "user_delete_cuti";
  static const userEditCuti = "user_edit_cuti";
  static const addCuti = "add_cuti";
  static const approvalCutiCard = "approval_card";

  // ====================== Modul fitur cuti ======================
  // Super Admin
  static const manageCuti = [
    approveCuti,
    declineCuti,
    deleteCuti,
    approvalCutiCard,
    editCuti,
  ];
  //User
  static const userCuti = [
    addCuti,
    userDeleteCuti,
    userEditCuti,
  ];

  // ====================== Fitur Lembur ======================
  static const approveLembur = "approve_lembur";
  static const declineLembur = "decline_lembur";
  static const deleteLembur = "delete_lembur";
  static const editLembur = "edit_lembur";
  static const userDeleteLembur = "user_delete_lembur";
  static const userEditLembur = "user_edit_lembur";
  static const addLembur = "add_lembur";
  static const approvalLemburCard = "approval_lembur";

  // ====================== Modul fitur cuti ======================
  // Super Admin
  static const manageLembur = [
    approveLembur,
    declineLembur,
    deleteLembur,
    approvalLemburCard,
    editLembur,
  ];
  //User
  static const userLembur = [
    addLembur,
    userDeleteLembur,
    userEditLembur,
  ];

// ====================== Fitur Dashboard ======================
  static const cardAdmin = "card_admin";
  static const cardUser = "card_user";
  static const karyawan = "management_karyawan";
  static const gaji = "gaji";
  static const department = "department";
  static const jabatan = "jabatan";
  static const peran = "peran";
  static const tentang = "tentang";
  static const logAktivitas = "log_aktivitas";
  static const pengaturan = "pengaturan";

  // ====================== Modul fitur cuti ======================
  // Super Admin
  static const dashboard = [
    cardAdmin,
    karyawan,
    gaji,
    department,
    jabatan,
    peran,
    tentang,
    logAktivitas,
    pengaturan,
  ];

  static const dashboardUser = [
    karyawan,
    cardUser,
    gaji,
    department,
    jabatan,
    peran,
    tentang,
    logAktivitas,
    pengaturan,
  ];

  // ====================== Modul fitur tugas ======================
  static const addTask = "add_task";
  static const manageTabelTask = "manage_tabel_task";
  static const userTabelTask = "user_tabel_task";

  static const manageTask = [
    addTask,
    manageTabelTask,
  ];

  static const userTask = [
    userTabelTask,
  ];
  // Contoh paket lain bisa dibuat seperti ini
  // static const ManageLembur = [approveLembur, declineLembur];
}
