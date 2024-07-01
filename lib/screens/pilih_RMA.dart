import 'package:flutter/material.dart';
import 'package:mikrotik/screens/form_rma_serial.dart';
import 'package:mikrotik/screens/form_rma_tanpa.dart';

class PilihRMA extends StatefulWidget {
  const PilihRMA({Key? key}) : super(key: key);

  @override
  _PilihRMAState createState() => _PilihRMAState();
}

class _PilihRMAState extends State<PilihRMA> {
  String selectedOption = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Pengajuan RMA'),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            // Padding(
            //   padding: const EdgeInsets.only(left: 10, top: 50, bottom: 20),
            //   child: Text(
            //     "Pilih",
            //     style: Theme.of(context).textTheme.headline6,
            //   ),
            // ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RadioListTile(
                    title: Text('Tanpa Serial Number'),
                    value: 'tanpaserial',
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value.toString();
                      });
                    },
                  ),
                  RadioListTile(
                    title: Text('Dengan Serial Number'),
                    value: 'denganserial',
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value.toString();
                      });
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 40, top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        if (selectedOption == "tanpaserial") {
                          print(selectedOption);
                          Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    const FormRmaTanpa(),
                              ));
                        } else if (selectedOption == "denganserial") {
                          print(selectedOption);
                          Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    const FormRmaSerial(),
                              ));
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute<void>(
                          //       builder: (BuildContext context) =>
                          //           const RegisterPerusahaanScreen(),
                          //     ));
                        }
                      },
                      child: Text("Lanjutkan"))
                ],
              ),
            )
          ],
        ));
  }
}
