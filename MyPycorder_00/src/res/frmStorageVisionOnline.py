# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'frmStorageVisionOnline.ui'
#
# Created: Wed Jun 05 12:00:50 2013
#      by: PyQt4 UI code generator 4.5.4
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

class Ui_frmStorageVisionOnline(object):
    def setupUi(self, frmStorageVisionOnline):
        frmStorageVisionOnline.setObjectName("frmStorageVisionOnline")
        frmStorageVisionOnline.resize(393, 222)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Preferred, QtGui.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(frmStorageVisionOnline.sizePolicy().hasHeightForWidth())
        frmStorageVisionOnline.setSizePolicy(sizePolicy)
        frmStorageVisionOnline.setFrameShape(QtGui.QFrame.Panel)
        frmStorageVisionOnline.setFrameShadow(QtGui.QFrame.Raised)
        self.gridLayout_2 = QtGui.QGridLayout(frmStorageVisionOnline)
        self.gridLayout_2.setObjectName("gridLayout_2")
        self.groupBox = QtGui.QGroupBox(frmStorageVisionOnline)
        self.groupBox.setObjectName("groupBox")
        self.formLayout = QtGui.QFormLayout(self.groupBox)
        self.formLayout.setContentsMargins(-1, -1, -1, 5)
        self.formLayout.setObjectName("formLayout")
        self.verticalLayout = QtGui.QVBoxLayout()
        self.verticalLayout.setObjectName("verticalLayout")
        self.gridLayout = QtGui.QGridLayout()
        self.gridLayout.setContentsMargins(-1, -1, -1, 5)
        self.gridLayout.setHorizontalSpacing(6)
        self.gridLayout.setObjectName("gridLayout")
        self.label = QtGui.QLabel(self.groupBox)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Preferred, QtGui.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.label.sizePolicy().hasHeightForWidth())
        self.label.setSizePolicy(sizePolicy)
        self.label.setMinimumSize(QtCore.QSize(0, 34))
        self.label.setMargin(2)
        self.label.setObjectName("label")
        self.gridLayout.addWidget(self.label, 2, 0, 1, 1)
        self.label_3 = QtGui.QLabel(self.groupBox)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Preferred, QtGui.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.label_3.sizePolicy().hasHeightForWidth())
        self.label_3.setSizePolicy(sizePolicy)
        self.label_3.setMargin(2)
        self.label_3.setObjectName("label_3")
        self.gridLayout.addWidget(self.label_3, 1, 0, 1, 1)
        self.label_4 = QtGui.QLabel(self.groupBox)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Preferred, QtGui.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.label_4.sizePolicy().hasHeightForWidth())
        self.label_4.setSizePolicy(sizePolicy)
        self.label_4.setMargin(2)
        self.label_4.setObjectName("label_4")
        self.gridLayout.addWidget(self.label_4, 0, 0, 1, 1)
        self.lineEditPath = QtGui.QLineEdit(self.groupBox)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Preferred, QtGui.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.lineEditPath.sizePolicy().hasHeightForWidth())
        self.lineEditPath.setSizePolicy(sizePolicy)
        self.lineEditPath.setMaximumSize(QtCore.QSize(16777215, 16777215))
        palette = QtGui.QPalette()
        brush = QtGui.QBrush(QtGui.QColor(240, 240, 240))
        brush.setStyle(QtCore.Qt.SolidPattern)
        palette.setBrush(QtGui.QPalette.Active, QtGui.QPalette.Base, brush)
        brush = QtGui.QBrush(QtGui.QColor(240, 240, 240))
        brush.setStyle(QtCore.Qt.SolidPattern)
        palette.setBrush(QtGui.QPalette.Inactive, QtGui.QPalette.Base, brush)
        brush = QtGui.QBrush(QtGui.QColor(240, 240, 240))
        brush.setStyle(QtCore.Qt.SolidPattern)
        palette.setBrush(QtGui.QPalette.Disabled, QtGui.QPalette.Base, brush)
        self.lineEditPath.setPalette(palette)
        self.lineEditPath.setReadOnly(True)
        self.lineEditPath.setObjectName("lineEditPath")
        self.gridLayout.addWidget(self.lineEditPath, 1, 1, 1, 1)
        self.lineEditFile = QtGui.QLineEdit(self.groupBox)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Preferred, QtGui.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.lineEditFile.sizePolicy().hasHeightForWidth())
        self.lineEditFile.setSizePolicy(sizePolicy)
        self.lineEditFile.setMaximumSize(QtCore.QSize(16777215, 16777215))
        palette = QtGui.QPalette()
        brush = QtGui.QBrush(QtGui.QColor(240, 240, 240))
        brush.setStyle(QtCore.Qt.SolidPattern)
        palette.setBrush(QtGui.QPalette.Active, QtGui.QPalette.Base, brush)
        brush = QtGui.QBrush(QtGui.QColor(240, 240, 240))
        brush.setStyle(QtCore.Qt.SolidPattern)
        palette.setBrush(QtGui.QPalette.Inactive, QtGui.QPalette.Base, brush)
        brush = QtGui.QBrush(QtGui.QColor(240, 240, 240))
        brush.setStyle(QtCore.Qt.SolidPattern)
        palette.setBrush(QtGui.QPalette.Disabled, QtGui.QPalette.Base, brush)
        self.lineEditFile.setPalette(palette)
        self.lineEditFile.setReadOnly(True)
        self.lineEditFile.setObjectName("lineEditFile")
        self.gridLayout.addWidget(self.lineEditFile, 0, 1, 1, 1)
        self.horizontalLayout = QtGui.QHBoxLayout()
        self.horizontalLayout.setSpacing(12)
        self.horizontalLayout.setObjectName("horizontalLayout")
        self.lineEditDiskSpace = QtGui.QLineEdit(self.groupBox)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Preferred, QtGui.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.lineEditDiskSpace.sizePolicy().hasHeightForWidth())
        self.lineEditDiskSpace.setSizePolicy(sizePolicy)
        self.lineEditDiskSpace.setMinimumSize(QtCore.QSize(80, 0))
        self.lineEditDiskSpace.setMaximumSize(QtCore.QSize(80, 16777215))
        palette = QtGui.QPalette()
        brush = QtGui.QBrush(QtGui.QColor(240, 240, 240))
        brush.setStyle(QtCore.Qt.SolidPattern)
        palette.setBrush(QtGui.QPalette.Active, QtGui.QPalette.Base, brush)
        brush = QtGui.QBrush(QtGui.QColor(240, 240, 240))
        brush.setStyle(QtCore.Qt.SolidPattern)
        palette.setBrush(QtGui.QPalette.Inactive, QtGui.QPalette.Base, brush)
        brush = QtGui.QBrush(QtGui.QColor(240, 240, 240))
        brush.setStyle(QtCore.Qt.SolidPattern)
        palette.setBrush(QtGui.QPalette.Disabled, QtGui.QPalette.Base, brush)
        self.lineEditDiskSpace.setPalette(palette)
        self.lineEditDiskSpace.setFrame(True)
        self.lineEditDiskSpace.setAlignment(QtCore.Qt.AlignCenter)
        self.lineEditDiskSpace.setReadOnly(True)
        self.lineEditDiskSpace.setObjectName("lineEditDiskSpace")
        self.horizontalLayout.addWidget(self.lineEditDiskSpace)
        self.label_2 = QtGui.QLabel(self.groupBox)
        self.label_2.setObjectName("label_2")
        self.horizontalLayout.addWidget(self.label_2)
        self.progressBar = QtGui.QProgressBar(self.groupBox)
        self.progressBar.setEnabled(False)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Preferred, QtGui.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.progressBar.sizePolicy().hasHeightForWidth())
        self.progressBar.setSizePolicy(sizePolicy)
        self.progressBar.setProperty("value", QtCore.QVariant(0))
        self.progressBar.setTextVisible(True)
        self.progressBar.setInvertedAppearance(False)
        self.progressBar.setObjectName("progressBar")
        self.horizontalLayout.addWidget(self.progressBar)
        self.gridLayout.addLayout(self.horizontalLayout, 2, 1, 1, 1)
        self.verticalLayout.addLayout(self.gridLayout)
        self.pushButtonRecord = QtGui.QPushButton(self.groupBox)
        self.pushButtonRecord.setMinimumSize(QtCore.QSize(100, 40))
        icon = QtGui.QIcon()
        icon.addPixmap(QtGui.QPixmap(":/icons/record_grey.png"), QtGui.QIcon.Normal, QtGui.QIcon.Off)
        icon.addPixmap(QtGui.QPixmap(":/icons/record.png"), QtGui.QIcon.Normal, QtGui.QIcon.On)
        self.pushButtonRecord.setIcon(icon)
        self.pushButtonRecord.setIconSize(QtCore.QSize(32, 32))
        self.pushButtonRecord.setCheckable(True)
        self.pushButtonRecord.setObjectName("pushButtonRecord")
        self.verticalLayout.addWidget(self.pushButtonRecord)
        self.formLayout.setLayout(0, QtGui.QFormLayout.FieldRole, self.verticalLayout)
        self.gridLayout_2.addWidget(self.groupBox, 0, 0, 1, 1)

        self.retranslateUi(frmStorageVisionOnline)
        QtCore.QMetaObject.connectSlotsByName(frmStorageVisionOnline)

    def retranslateUi(self, frmStorageVisionOnline):
        frmStorageVisionOnline.setWindowTitle(QtGui.QApplication.translate("frmStorageVisionOnline", "Frame", None, QtGui.QApplication.UnicodeUTF8))
        self.groupBox.setTitle(QtGui.QApplication.translate("frmStorageVisionOnline", "Data Storage", None, QtGui.QApplication.UnicodeUTF8))
        self.label.setText(QtGui.QApplication.translate("frmStorageVisionOnline", "Available\n"
"Disk Space", None, QtGui.QApplication.UnicodeUTF8))
        self.label_3.setText(QtGui.QApplication.translate("frmStorageVisionOnline", "Path", None, QtGui.QApplication.UnicodeUTF8))
        self.label_4.setText(QtGui.QApplication.translate("frmStorageVisionOnline", "File", None, QtGui.QApplication.UnicodeUTF8))
        self.label_2.setText(QtGui.QApplication.translate("frmStorageVisionOnline", "[d:h:m]", None, QtGui.QApplication.UnicodeUTF8))
        self.pushButtonRecord.setText(QtGui.QApplication.translate("frmStorageVisionOnline", "Record", None, QtGui.QApplication.UnicodeUTF8))

import resources_rc