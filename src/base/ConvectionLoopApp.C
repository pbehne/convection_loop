#include "ConvectionLoopApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
ConvectionLoopApp::validParams()
{
  InputParameters params = MooseApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;

  return params;
}

ConvectionLoopApp::ConvectionLoopApp(InputParameters parameters) : MooseApp(parameters)
{
  ModulesApp::registerAllObjects<ConvectionLoopApp>(_factory, _action_factory, _syntax);
}

ConvectionLoopApp::~ConvectionLoopApp() {}

void
ConvectionLoopApp::registerApps()
{
  registerApp(ConvectionLoopApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
ConvectionLoopApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  ModulesApp::registerAllObjects<ConvectionLoopApp>(f, af, s);
}
extern "C" void
ConvectionLoopApp__registerApps()
{
  ConvectionLoopApp::registerApps();
}
