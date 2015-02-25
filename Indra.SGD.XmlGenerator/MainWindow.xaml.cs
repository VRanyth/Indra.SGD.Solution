using Indra.SGD.XmlGenerator.Engines;
using Microsoft.Win32;
using System;
using System.Windows;
using System.Xml;

namespace Indra.SGD.XmlGenerator
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
        }


        private void Button_Click_1(object sender, RoutedEventArgs e)
        {
            try
            {
                OpenFileDialog dlg = new OpenFileDialog();
                dlg.Multiselect = false;
                dlg.Filter = "Excel files (*.xls; *.xlsx)|*.xls; *.xlsx|All Files (*.*)|*.*";
                dlg.Title = "Select File";
                Nullable<bool> result = dlg.ShowDialog();
                if (result == true)
                {
                    txtDiretorio.Text = dlg.FileName.ToString();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private XmlDocument GetDefinitionXml()
        {
            XmlDocument doc = new XmlDocument();

            //(1) the xml declaration is recommended, but not mandatory
            XmlDeclaration xmlDeclaration = doc.CreateXmlDeclaration("1.0", "UTF-8", null);
            XmlElement root = doc.DocumentElement;
            doc.InsertBefore(xmlDeclaration, root);
            return doc;
        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {

            MsftExcelEngine xls = null;
            try
            {
                if (!string.IsNullOrEmpty(txtDiretorio.Text))
                {

                    XmlDocument doc = GetDefinitionXml();
                    XmlElement element1 = doc.CreateElement("Folders");


                    xls = new MsftExcelEngine();
                    xls.Open(txtDiretorio.Text, true);
                    int index = 1;
                    while (!string.IsNullOrEmpty(xls.CellsRead("A" + index)))
                    {
                        string description = "Descrição";
                        XmlElement folder = doc.CreateElement("Folder");
                        folder.SetAttribute("Name", xls.CellsRead("A" + index));
                        folder.SetAttribute("Description", description + " " + xls.CellsRead("A" + index));
                        element1.AppendChild(folder);

                        index++;
                    }
                    XmlElement elementoDiv = doc.CreateElement("Folder");
                    elementoDiv.SetAttribute("Name", "Divulgação");
                    elementoDiv.SetAttribute("Description", "Descrição Divulgação");
                    element1.AppendChild(elementoDiv);


                    XmlElement elementoPart = doc.CreateElement("Folder");
                    elementoPart.SetAttribute("Name", "Partilha");
                    elementoPart.SetAttribute("Description", "Descrição Partilha");
                    XmlElement elementFolders = doc.CreateElement("Folders");

                    int column = 2;
                    while (!string.IsNullOrEmpty(xls.CellsRead(xls.GetExcelColumnName(column) + 1)))
                    {
                        for (int i = 1; i < index; i++)
                        {
                            if (column - 1 != i)
                            {
                                XmlElement elementosPartilha = doc.CreateElement("Folder");
                                elementosPartilha.SetAttribute("Name", xls.CellsRead(xls.GetExcelColumnName(column) + i).Split('/')[0]);
                                elementosPartilha.SetAttribute("Description", "Descrição Partilha " + xls.CellsRead(xls.GetExcelColumnName(column) + i));
                                elementFolders.AppendChild(elementosPartilha);
                            }
                        }
                        column++;
                    }
                    elementoPart.AppendChild(elementFolders);
                    element1.AppendChild(elementoPart);
                    doc.AppendChild(element1);
                    doc.Save(Environment.GetFolderPath(Environment.SpecialFolder.Desktop) + "\\folder.xml");
                    MessageBox.Show("concluido com sucesso");
                }
                else
                    MessageBox.Show("Selecione um ficheiro.");
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
                MessageBox.Show("concluido com erro");
            }
            finally
            {
                if (xls != null)
                {
                    xls.Close();
                    xls.Quit();
                }

            }
        }

        private void Button_Click_2(object sender, RoutedEventArgs e)
        {
            MsftExcelEngine xls = null;
            try
            {
                if (!string.IsNullOrEmpty(txtDiretorio.Text))
                {
                    xls = new MsftExcelEngine();
                    xls.Open(txtDiretorio.Text, true);

                    XmlDocument doc = GetDefinitionXml();

                    XmlElement elementPrinc = doc.CreateElement("Taxonomy");

                    XmlElement elementPrinc1 = doc.CreateElement("TermStore");
                    elementPrinc1.SetAttribute("name", "Managed Metadata Service Application");
                    elementPrinc1.SetAttribute("enable", "true");
                    XmlElement elementPrinc2 = doc.CreateElement("TaxonomyGroup");
                    elementPrinc2.SetAttribute("name", "");
                    elementPrinc2.SetAttribute("enable", "true");
                    XmlElement elementPrinc3 = doc.CreateElement("TermSet");
                    elementPrinc3.SetAttribute("name", "");
                    elementPrinc3.SetAttribute("guid", "");
                    elementPrinc3.SetAttribute("lcid", "2070");
                    elementPrinc3.SetAttribute("isOpenForTermCreation", "false");
                    elementPrinc3.SetAttribute("enable", "");

                    AppendChild(elementPrinc3, xls, doc, 1, true);

                    elementPrinc2.AppendChild(elementPrinc3);
                    elementPrinc1.AppendChild(elementPrinc2);
                    elementPrinc.AppendChild(elementPrinc1);
                    doc.AppendChild(elementPrinc);
                    doc.Save(Environment.GetFolderPath(Environment.SpecialFolder.Desktop) + "\\folder.xml");
                    MessageBox.Show("concluido com sucesso");
                }
                else
                    MessageBox.Show("Selecione um ficheiro.");
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
                MessageBox.Show("concluido com erro");
            }
            finally
            {
                if (xls != null)
                {
                    xls.Close();
                    xls.Quit();
                }

            }
        }

        private int AppendChild(XmlElement ElementAppendChild, MsftExcelEngine xls, XmlDocument doc, int index, bool first)
        {
            if (xls.CellsRead("A" + index).Split('.').Length < xls.CellsRead("A" + (index + 1)).Split('.').Length)
            {
                int antIndex = index;
                while (index == 1 || (!string.IsNullOrEmpty(xls.CellsRead("A" + (index + 1))) && xls.CellsRead("A" + index).Split('.').Length < xls.CellsRead("A" + (index + 1)).Split('.').Length && xls.CellsRead("A" + antIndex).Split('.').Length == xls.CellsRead("A" + index).Split('.').Length))
                {
                    XmlElement elementBase = CreateTerm(xls, doc, index, "B");
                    XmlElement Terms = doc.CreateElement("Terms");
                    //MessageBox.Show(xls.CellsRead("A" + index));
                    index = AppendChild(Terms, xls, doc, ++index, false);
                    elementBase.AppendChild(Terms);
                    ElementAppendChild.AppendChild(elementBase);
                    index++;
                }
                index--;
                return index;
            }
            else if (xls.CellsRead("A" + index).Split('.').Length == xls.CellsRead("A" + (index + 1)).Split('.').Length)
            {
                //MessageBox.Show(xls.CellsRead("A" + index));
                XmlElement elementBase = CreateTerm(xls, doc, index, "C");
                XmlElement Terms = doc.CreateElement("Terms");
                elementBase.AppendChild(Terms);
                ElementAppendChild.AppendChild(elementBase);
                return AppendChild(ElementAppendChild, xls, doc, ++index, false);
            }
            else
            {
                //MessageBox.Show(xls.CellsRead("A" + index));
                XmlElement elementBase = CreateTerm(xls, doc, index, "C");
                XmlElement Terms = doc.CreateElement("Terms");
                elementBase.AppendChild(Terms);
                ElementAppendChild.AppendChild(elementBase);
                return index;
            }



        }

        private static XmlElement CreateTerm(MsftExcelEngine xls, XmlDocument doc, int index, string Column)
        {
            XmlElement elementBase = doc.CreateElement("Term");
            elementBase.SetAttribute("Name", xls.CellsRead("A" + index) + " " + xls.CellsRead(Column + index));
            elementBase.SetAttribute("Description", "Description " + xls.CellsRead(Column + index));
            elementBase.SetAttribute("lcid", "2070");
            elementBase.SetAttribute("guid", xls.CellsRead("D" + index));
            elementBase.SetAttribute("enable", "true");
            XmlElement LocalCustomProperties = doc.CreateElement("LocalCustomProperties");
            elementBase.AppendChild(LocalCustomProperties);
            return elementBase;
        }

        private void Button_Click_3(object sender, RoutedEventArgs e)
        {
            MsftExcelEngine xls = null;
            try
            {
                if (!string.IsNullOrEmpty(txtDiretorio.Text))
                {
                    xls = new MsftExcelEngine();
                    xls.Open(txtDiretorio.Text, false);


                    int index = 1;
                    while (!string.IsNullOrEmpty(xls.CellsRead("A" + index)))
                    {
                        xls.Cells("D" + index, Guid.NewGuid().ToString());
                        index++;
                    }
                    xls.Save();
                    MessageBox.Show("concluido com sucesso");
                }
                else
                    MessageBox.Show("Selecione um ficheiro.");
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
                MessageBox.Show("concluido com erro");
            }
            finally
            {
                if (xls != null)
                {

                    xls.Close();
                    xls.Quit();
                }

            }

        }

        private void Button_Click_4(object sender, RoutedEventArgs e)
        {

            MsftExcelEngine xls = null;
            try
            {
                if (!string.IsNullOrEmpty(txtDiretorio.Text))
                {

                    XmlDocument doc = GetDefinitionXml();
                    XmlElement element1 = doc.CreateElement("Profiles");


                    xls = new MsftExcelEngine();
                    xls.Open(txtDiretorio.Text, true);
                    int index = 1;
                    while (!string.IsNullOrEmpty(xls.CellsRead("A" + index)))
                    {
                        XmlElement profile = doc.CreateElement("Profile");
                        profile.SetAttribute("Name", xls.CellsRead("B" + index));
                        profile.SetAttribute("Description", xls.CellsRead("C" + index));
                        profile.SetAttribute("Profile", xls.CellsRead("D" + index));

                        element1.AppendChild(profile);

                        index++;
                    }

                    doc.AppendChild(element1);
                    doc.Save(Environment.GetFolderPath(Environment.SpecialFolder.Desktop) + "\\Profiles.xml");
                    MessageBox.Show("concluido com sucesso");
                }
                else
                    MessageBox.Show("Selecione um ficheiro.");
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
                MessageBox.Show("concluido com erro");
            }
            finally
            {
                if (xls != null)
                {
                    xls.Close();
                    xls.Quit();
                }

            }
        }
    }
}
